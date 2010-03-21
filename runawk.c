/*
 * Copyright (c) 2007-2008 Aleksey Cheusov <vle@gmx.net>
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <limits.h>
#include <signal.h>

#ifdef HAVE_CONFIG_H
/* if you need, add extra includes to config.h */
#include "config.h"
#endif

#ifndef BUFSIZ
#define BUFSIZ 4096
#endif

#ifndef STDIN_FILENAME
#define STDIN_FILENAME "/dev/stdin"
#endif

#ifndef AWK_PROG
#define AWK_PROG "awk"
#endif

#ifndef ARRAY_SZ
#define ARRAY_SZ 1000
#endif

#ifndef RUNAWK_VERSION
#define RUNAWK_VERSION "x.y.z"
#endif

#ifndef TEMPDIR
#define TEMPDIR "/tmp"
#endif

#ifndef MODULESDIR
#define MODULESDIR "/usr/local/share/runawk"
#endif

static void usage (void)
{
	puts ("\
runawk - wrapper for an AWK interpreter\n\
usage: runawk [OPTIONS] program_file [arguments...]\n\
       runawk [OPTIONS] -e program [arguments...]\n\
OPTIONS:\n\
  -h|--help           display this screen\n\
  -V|--version        display version information\n\
  -d|--debug          debugging mode, just list argv array for awk,\n\
                      awk interpreter is not run\n\
  -e|--execute <program>  program to run\n\
  -v|--assign <var=val>   assign the value val to the variable var\n\
  -f|--file <awk_module>  add awk_module to a program\n\
  -t                  create a temporary directory and pass it to\n\
                      AWK interpreter subprocess\n\
  -i|--with-stdin     always add \"stdin\" file name to awk arguments\n\
  -I|--without-stdin  do not add \"stdin\" file name to awk arguments\n\
");
}

static const char *runawk_version = RUNAWK_VERSION;

static void version (void)
{
	printf ("runawk %s written by Aleksey Cheusov\n", runawk_version);
}

static int create_tmpdir = 0;

static pid_t awk_pid = -1;

static int killing_sig = 0;

static char *includes [ARRAY_SZ];
static int includes_count = 0;

static int double_dash = 0;

static char temp_fn [PATH_MAX] = "/tmp/runawk.XXXXXX";
static int temp_fn_created = 0;

static char *temp_dir = NULL;

static char *awkpath      = NULL;
static size_t awkpath_len = 0;

static char cwd [PATH_MAX];

static const char *interp     = AWK_PROG;
static const char *sys_awkdir = MODULESDIR;

static char *interp_var = NULL;

static int debug = 0;

static int add_stdin = 0;

static char *new_argv [ARRAY_SZ];
static int new_argc = 0;

static void clean_and_exit (int status)
{
	char buffer [4000];

	if (temp_fn_created)
		unlink (temp_fn);

	if (temp_dir){
		snprintf (buffer, sizeof (buffer), "rm -rf %s", temp_dir);
		if (-1 == system (buffer))
			perror ("system(3) failed:");

		if (temp_dir)
			free (temp_dir);
	}

	if (awkpath)
		free (awkpath);

	if (killing_sig)
		exit (128 + killing_sig);
	else
		exit (status);
}

static void mktempdir (void)
{
	const char *dir = getenv ("RUNAWK_TMPDIR");
	if (!dir)
		dir = getenv ("TMPDIR");
	if (!dir)
		dir = TEMPDIR;

	temp_dir = tempnam (dir, "awk.");
	if (!temp_dir){
		perror ("tempnam(3) failed");
		clean_and_exit (52);
	}

	if (mkdir (temp_dir, 0700)){
		perror ("mkdir(3) failed");
		clean_and_exit (53);
	}
}

static char *xstrdup (const char *s)
{
	char *ret = strdup (s);
	if (!ret){
		perror ("strdup(3) failed");
		clean_and_exit (33);
	}

	return ret;
}

static void *xmalloc (size_t size)
{
	char *ret = malloc (size);
	if (!ret){
		perror ("malloc(3) failed");
		clean_and_exit (33);
	}

	return ret;
}

static void xputenv (char *s)
{
	if (putenv (s)){
		perror ("putenv(3) failed");
		clean_and_exit (43);
	}
}

static const char *search_file (const char *dir, const char *name)
{
	/* search in AWKPATH env. */
	const char *curr_dir = NULL;
	char buf [PATH_MAX];
	size_t i;

	/* dir argument */
	snprintf (buf, sizeof (buf), "%s/%s", dir, name);
	if (!access (buf, R_OK)){
		return xstrdup (buf);
	}

	/* AWKPATH env. and system paths */
	for (i = 0; i < awkpath_len; ++i){
		if (awkpath [i] && (i == 0 || awkpath [i-1] == 0)){
			curr_dir = awkpath + i;
			snprintf (buf, sizeof (buf), "%s/%s", curr_dir, name);
			if (!access (buf, R_OK)){
				return xstrdup (buf);
			}
		}
	}

	return NULL;
}

static void invalid_directive (int num, const char *line, const char *fn)
{
	char *copy = xstrdup (line);
	char * nl = strchr (copy, '\n');

	if (nl)
		*nl = 0;

	fprintf (stderr,
			 "error: invalid directive at line #%d,\n line=`%s`\n file=`%s`\n",
			 num, copy, fn);

	free (copy);
}

static int add_file_uniq (const char *dir, const char *name, int safe_use);

static char *extract_qstring (
	const char *line, int line_num, const char *fn, const char *s)
{
	const char *p = NULL;
	const char *n = NULL;
	char *ret = NULL;
	size_t len = 0;

	p = s + strspn (s, " ");
	if (*p != '"'){
		invalid_directive (line_num, line, fn);
		clean_and_exit (37);
	}

	++p;

	n = strpbrk (p, "\"\n");
	if (!n || *n == '\n'){
		invalid_directive (line_num, line, fn);
		clean_and_exit (37);
	}

	len = n - p;
	ret = xmalloc (len+1);
	memcpy ((void *) ret, (const void *) p, len);
	ret [len] = 0;
	
	return ret;
}

static int add_file_uniq_safe (const char *dir, const char *name)
{
	char buffer [4000];
	const char *fn;

	if (name [0] == '~'){
		snprintf (buffer, sizeof (buffer), "%s%s", getenv ("HOME"), name+1);
		fn = buffer;
	}else{
		fn = name;
	}

	return add_file_uniq (dir, fn, 1);
}

typedef enum {
	qstr_spaces,
	qstr_str,
} qstr_state_t;

static void list_of_qstrings (
	const char *dir,
	int line_num,
	const char *fn,
	const char *line,
	const char *s,
	int (*fun) (const char *dir, const char *name))
{
	char buffer [2000];
	const char *p;
	const char *start = NULL;
	size_t len;
	int state = qstr_spaces;
	int success = 0;

	for (p=s; *p; ++p){
		switch (state){
			case qstr_spaces:
				switch (*p){
					case ' ':
					case '\t':
					case '\r':
						break;
					case '\n':
						goto eol;
					case '"':
						state = qstr_str;
						start = p+1;
						break;
					default:
						invalid_directive (line_num, line, fn);
						clean_and_exit (51);
				}
				break;
			case qstr_str:
				switch (*p){
					case '"':
						len = p-start;
						if (len+1 > sizeof (buffer))
							len = sizeof (buffer) - 1;

						memcpy (buffer, start, len);
						buffer [len] = 0;
						state = qstr_spaces;

						success = (success || fun (dir, buffer));
						break;
					default:
						break;
				}
				break;
		}
	}

 eol:
	if (state == qstr_str){
		invalid_directive (line_num, line, fn);
		clean_and_exit (52);
	}
}

static void scan_buffer (
	const char *name, const char *dir,
	const char *buffer, off_t sz,
	int allow_spaces)
{
	char *env_str = NULL;
	const char *p = buffer;
	int line_num = 1;

	for (; sz--; ++p){
		if (*p == '\n')
			++line_num;

		if (*p != '#')
			continue;

		if (p != buffer){
			if (allow_spaces){
				switch (p[-1]){
					case '\n':
					case ' ':
					case '\t':
						break;
					default:
						continue;
				}
			}else{
				if (p [-1] != '\n')
					continue;
			}
		}

		if (!strncmp (p, "#use ", 5)){
			add_file_uniq (dir, extract_qstring (p, line_num, name, p + 5), 0);
		}else if (!strncmp (p, "#safe-use ", 10)){
			list_of_qstrings (dir, line_num, name, p, p+10, add_file_uniq_safe);
		}else if (!strncmp (p, "#interp ", 8)){
			interp = extract_qstring (p, line_num, name, p + 8);
		}else if (!strncmp (p, "#interp-var ", 12)){
			interp_var = extract_qstring (p, line_num, name, p + 12);
		}else if (!strncmp (p, "#env ", 5)){
			env_str = (char *) extract_qstring (p, line_num, name, p + 5);
			xputenv (env_str);
		}
	}
}

static int scan_file (const char *name, int safe_use)
{
	char dir [PATH_MAX];
	FILE *fd      = NULL;
	size_t len    = 0;
	struct stat stat_buf;
	char *buffer = NULL;
	off_t file_size = 0;
	size_t n = 0;

	/**/
	len = strlen (name);
	strncpy (dir, name, sizeof (dir));
	while (len--){
		if (dir [len] == '/'){
			dir [len] = 0;
			break;
		}
	}

	/**/
	if (stat (name, &stat_buf)){
		if (safe_use)
			return 0;

		fprintf (stderr, "stat(\"%s\") failed: %s\n", name, strerror (errno));
		clean_and_exit (35);
	}
	file_size = stat_buf.st_size;

	fd = fopen (name, "r");
	if (!fd){
		fprintf (stderr, "fopen(%s) failed: %s\n", name, strerror (errno));
		clean_and_exit (35);
	}

	buffer = xmalloc (file_size + 1);

	n = fread (buffer, 1, file_size, fd);
	if (n < file_size){
		perror ("fread(3) failed");
		clean_and_exit (35);
	}
	buffer [file_size] = 0;

	scan_buffer (name, dir, buffer, file_size, 0);

	free (buffer);

	if (fclose (fd)){
		perror ("fclose(3) failed");
		clean_and_exit (36);
	}

	return 1;
}

static void ll_push (
	const char *item,
	char **array,
	int *array_size)
{
	if (*array_size == ARRAY_SZ){
		fprintf (stderr, "too big array\n");
		clean_and_exit (31);
	}

	array [*array_size] = (item ? xstrdup (item) : NULL);
	++*array_size;
}

static void add_buffer (const char *buffer, size_t len)
{
	int fd = -1;

	/* recursive snanning for #xxx directives */
	scan_buffer ("", "-", buffer, len, 1);

	if (includes_count == 0 && !double_dash){
		ll_push (buffer, new_argv, &new_argc);
	}else{
		fd = mkstemp (temp_fn);
		temp_fn_created = 1;
		if (fd == -1){
			perror ("mkstemp(3) failed");
			clean_and_exit (40);
		}
		if (write (fd, buffer, len) != (ssize_t) len){
			perror ("write(2) failed");
			clean_and_exit (40);
		}
		if (close (fd)){
			perror ("close(2) failed");
			clean_and_exit (40);
		}

		/* add to queue */
		ll_push ("-f", new_argv, &new_argc);
		ll_push (temp_fn, new_argv, &new_argc);
		ll_push (temp_fn, includes, &includes_count);
	}
}

static int add_file (const char *dir, const char *name, int safe_use)
{
	const char *new_name = NULL;
	size_t len;

	if (name [0] != '/'){
		/* name -> path */
		new_name = search_file (dir, name);
		if (!new_name){
			if (safe_use)
				return 0;

			fprintf (stderr, "Cannot find module `%s`, check AWKPATH environment variable\n", name);
			clean_and_exit (34);
		}
		name = new_name;
	}

	/* recursive snanning for #xxx directives */
	if (scan_file (name, safe_use)){
		/* add to queue */
		len = strlen (name);
		if (len > 11 && !strcmp (name+len-12, "/tmpfile.awk")){
			create_tmpdir = 1;
		}

		ll_push ("-f", new_argv, &new_argc);
		ll_push (name, new_argv, &new_argc);
		ll_push (name, includes, &includes_count);
		return 1;
	}else{
		return 0;
	}
}

static int add_file_uniq (
	const char *dir, const char *name, int safe_use)
{
	int i;
	const char *p;
	const char *inc;

	for (i=0; i < includes_count; ++i){
		inc = includes [i];
		p = strstr (inc, name);

		if (p && (p == inc || (p [-1] == '/' && p [strlen (p)] == 0))){
			return 1;
		}
	}

	return add_file (dir, name, safe_use);
}

static void process_opt (char opt)
{
	switch (opt){
		case 'h':
			usage ();
			clean_and_exit (0);
		case 'V':
			version ();
			clean_and_exit (0);
		case 'd':
			debug = 1;
			break;
		case 'i':
			add_stdin = 1;
			break;
		case 'I':
			add_stdin = 0;
			break;
		case 't':
			create_tmpdir = 1;
			break;
		default:
			abort ();
	}
}

static void handler (int sig)
{
//	if (temp_fn_created)
//		unlink (temp_fn);

//	fprintf (stderr, "sig=%li\n", (long) sig);
//	fprintf (stderr, "pid=%li\n", (long) awk_pid);
	killing_sig = sig;
	if (awk_pid != -1){
		kill (awk_pid, sig);
	}

//	struct sigaction sa;
//	sa.sa_handler = SIG_DFL;
//	sigemptyset (&sa.sa_mask);
//	sa.sa_flags = 0;
//	sigaction (sig, &sa, NULL);

//	kill (getpid (), sig);
}

static void set_sig_handler (void)
{
	static const int sigs [] = {
		SIGINT, SIGQUIT, SIGTERM,
		SIGHUP, SIGPIPE
	};

	struct sigaction sa;
	size_t i;

	sa.sa_handler = handler;
	sigemptyset (&sa.sa_mask);
	sa.sa_flags = 0;
	for (i=0; i < sizeof (sigs)/sizeof (sigs [0]); ++i){
		int sig = sigs [i];
		sigaction (sig, &sa, NULL);
	}
}

static void putenv_RUNAWK_MODx (void)
{
	int i;
	char buf [30 + PATH_MAX];

	/* RUNAWK_MODC */
	snprintf (buf, sizeof (buf), "RUNAWK_MODC=%i", includes_count);
	xputenv (xstrdup (buf));

	/* RUNAWK_MODV */
	for (i=0; i < includes_count; ++i){
		snprintf (buf, sizeof (buf), "RUNAWK_MODV_%i=%s", i, includes [i]);
		xputenv (xstrdup (buf));
	}
}

int main (int argc, char **argv)
{
	char buffer [4000];
	const char *progname   = NULL;
	int child_status       = 0;
	const char *p          = NULL;
	const char *env_interp = getenv ("RUNAWK_AWKPROG");
	const char *prog_specified = NULL;
	const char *awkpath_env = NULL;

	int i;
	size_t j;

	set_sig_handler ();

	/* environment RUNAWK_AWKPROG overrides compile-time option */
	if (env_interp){
		interp = env_interp;
	}

	--argc, ++argv;

	if (argc == 0){
		usage ();
		return 30;
	}

	/* AWKPATH env. */
	awkpath_env = getenv ("AWKPATH");
	if (!awkpath_env)
		awkpath_env = "";

	awkpath_len = strlen (awkpath_env) + 1 + strlen (sys_awkdir);
	awkpath = xmalloc (awkpath_len + 1);
	snprintf (awkpath, awkpath_len + 1, "%s:%s", awkpath_env, sys_awkdir);

	for (j=0; j < awkpath_len; ++j){
		if (awkpath [j] == ':'){
			awkpath [j] = 0;
		}
	}

	/* cwd */
	if (!getcwd (cwd, sizeof (cwd))){
		perror ("getcwd (3) failed");
		clean_and_exit (32);
	}

	ll_push (NULL, new_argv, &new_argc); /* progname */

	/* options, no getopt(3) here */
	for (; argc && argv [0][0] == '-'; --argc, ++argv){
		/* --help */
		if (!strcmp (argv [0], "--help")){
			process_opt ('h');
			abort ();
		}

		/* --version */
		if (!strcmp (argv [0], "--version")){
			process_opt ('V');
			abort ();
		}

		/* --debug */
		if (!strcmp (argv [0], "--debug")){
			process_opt ('d');
			continue;
		}

		/* --with-stdin */
		if (!strcmp (argv [0], "--with-stdin")){
			process_opt ('i');
			continue;
		}

		/* --without-stdin */
		if (!strcmp (argv [0], "--without-stdin")){
			process_opt ('I');
			continue;
		}

		/* -v|--assign */
		if (!strcmp (argv [0], "-v") || !strcmp (argv [0], "--assign")){
			if (argc == 1){
				fprintf (stderr, "missing argument for -v option\n");
				clean_and_exit (39);
			}

			ll_push ("-v",     new_argv, &new_argc);
			ll_push (argv [1], new_argv, &new_argc);

			--argc;
			++argv;
			continue;
		}

		/* -f|--file */
		if (!strcmp (argv [0], "-f") || !strcmp (argv [0], "--file")){
			if (argc == 1){
				fprintf (stderr, "missing argument for -f option\n");
				clean_and_exit (39);
			}

			add_file (cwd, argv [1], 0);

			--argc;
			++argv;
			continue;
		}

		/* -e */
		if (!strcmp (argv [0], "-e") || !strcmp (argv [0], "--execute")){
			if (argc == 1){
				fprintf (stderr, "missing argument for -e option\n");
				clean_and_exit (39);
			}

			prog_specified = argv [1];

			--argc;
			++argv;
			continue;
		}

		/* -- */
		if (!strcmp (argv [0], "--")){
			double_dash = 1;
			--argc;
			++argv;
			break;
		}

		/* -h -V -d -i -I etc. */
		for (p = argv [0]+1; *p; ++p){
			switch (*p){
				case 'h':
				case 'V':
				case 'd':
				case 'i':
				case 'I':
				case 't':
					process_opt (*p);
					break;
				default:
					fprintf (stderr, "unknown option -%c\n", *p);
					clean_and_exit (1);
			}
		}
	}

	progname = interp;

	/* */
	if (prog_specified){
		add_buffer (prog_specified, strlen (prog_specified));
	}else{
		/* program_file */
		if (argc < 1){
			usage ();
			clean_and_exit (30);
		}

		--argc;
		add_file (cwd, *argv, 0);
		progname = *argv;
#if 0
		setprogname (*argv);
		setproctitle (*argv);
#endif
		++argv;
	}

	/* AWK interpreter name */
	if (interp_var)
		interp_var = getenv (interp_var);

	if (interp_var && interp_var [0])
		interp = interp_var;

	/* exec */
	new_argv [0] = xstrdup (progname);

	if (includes_count)
		ll_push ("--", new_argv, &new_argc);

	for (i=0; i < argc; ++i){
		ll_push (argv [i], new_argv, &new_argc);
	}

	if (add_stdin){
		xputenv (xstrdup ("RUNAWK_ART_STDIN=1"));
		ll_push (STDIN_FILENAME, new_argv, &new_argc);
	}

	ll_push (NULL, new_argv, &new_argc);

	putenv_RUNAWK_MODx ();

	/* create temporary directory */
	if (create_tmpdir){
		mktempdir ();
		snprintf (buffer, sizeof (buffer), "_RUNAWK_TMPDIR=%s", temp_dir);
		xputenv (buffer);
	}

	/**/
	if (debug){
		for (i=0; i < new_argc - 1; ++i){
			printf ("new_argv [%d] = %s\n", i, new_argv [i]);
		}
	}else{
		awk_pid = fork ();
		switch (awk_pid){
			case -1:
				perror ("fork(2) failed");
				clean_and_exit (42);
				break;

			case 0:
				/* child */
				execvp (interp, (char *const *) new_argv);
				fprintf (stderr, "running '%s' failed: %s\n", interp, strerror (errno));
				exit (1);
				break;

			default:
				/* parent */
				waitpid (-1, &child_status, 0);
				if (killing_sig){
					clean_and_exit (0);
				}else if (WIFSIGNALED (child_status)){
					clean_and_exit (128 + WTERMSIG (child_status));
				}else if (WIFEXITED (child_status)){
					clean_and_exit (WEXITSTATUS (child_status));
				}else{
					clean_and_exit (200);
				}
		}
	}

	clean_and_exit (0);
	return 0; /* this should not happen but fixes gcc warning */
}
