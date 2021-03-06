/*
 * Copyright (c) 2007-2014 Aleksey Cheusov <vle@gmx.net>
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

#include "common.h"

#include "dynarray.h"
#include "file_hier.h"

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
  -h        display this screen\n\
  -V        display version information\n\
  -d        debugging mode, list argv array for awk and\n\
            do not run AWK interpreter\n\
  -e <program>     program to run\n\
  -v <var=val>     assign the value val to the variable var\n\
  -f <awk_module>  add awk_module to a program\n\
  -t        create a temporary directory and pass it to\n\
            AWK interpreter subprocess\n\
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

static dynarray_t new_argv;
static dynarray_t includes;

static void remove_file (const char *fn)
{
	if (unlink (fn)){
		fprintf (stderr, "unlink(\"%s\") failed: %s\n", fn, strerror (errno));
	}
}

static void remove_dir (const char *dir)
{
	if (rmdir (dir)){
		fprintf (stderr, "rmdir(\"%s\") failed: %s\n", dir, strerror (errno));
	}
}

static void clean_and_exit (int status)
{
	const char *keep = getenv ("RUNAWK_KEEPTMP");

	if (!keep && temp_fn_created)
		unlink (temp_fn);

	if (temp_dir){
		if (!keep)
			file_hier (temp_dir, remove_file, remove_dir);

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
	qstr_str
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
	if (n < (size_t) file_size){
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

static void add_buffer (const char *buffer, size_t len)
{
	int fd = -1;

	/* recursive snanning for #xxx directives */
	scan_buffer ("", "-", buffer, len, 1);

	if (includes.size == 0 && !double_dash){
		da_push_dup (&new_argv, buffer);
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
		da_push_dup (&new_argv, "-f");
		da_push_dup (&new_argv, temp_fn);
		da_push_dup (&includes, temp_fn);
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

		da_push_dup (&new_argv, "-f");
		da_push_dup (&new_argv, name);
		da_push_dup (&includes, name);
		return 1;
	}else{
		return 0;
	}
}

static int add_file_uniq (
	const char *dir, const char *name, int safe_use)
{
	size_t i;
	const char *p;
	const char *inc;

	for (i=0; i < includes.size; ++i){
		inc = includes.array [i];
		p = strstr (inc, name);

		if (p && (p == inc || (p [-1] == '/' && p [strlen (p)] == 0))){
			return 1;
		}
	}

	return add_file (dir, name, safe_use);
}

static void handler (int sig)
{
	killing_sig = sig;
	if (awk_pid != -1){
		kill (awk_pid, sig);
	}
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
	size_t i;
	char buf [30 + PATH_MAX];

	/* RUNAWK_MODC */
	snprintf (buf, sizeof (buf), "RUNAWK_MODC=%u",
			  (unsigned) includes.size);
	xputenv (xstrdup (buf));

	/* RUNAWK_MODV */
	for (i=0; i < includes.size; ++i){
		snprintf (buf, sizeof (buf), "RUNAWK_MODV_%u=%s",
				  (unsigned) i, includes.array [i]);
		xputenv (xstrdup (buf));
	}
}

int main (int argc, char **argv)
{
	char buffer [4000];
	const char *progname   = NULL;
	int child_status       = 0;
	const char *env_interp = getenv ("RUNAWK_AWKPROG");
	const char *prog_specified = NULL;
	const char *awkpath_env = NULL;
	int c;

	size_t i;
	size_t j;

	da_init (&new_argv);
	da_init (&includes);

	set_sig_handler ();

	/* environment RUNAWK_AWKPROG overrides compile-time option */
	if (env_interp){
		interp = env_interp;
	}

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

	da_push_dup (&new_argv, NULL); /* progname */

	while (c = getopt (argc, argv, "+de:f:F:htTVv:"), c != EOF){
		switch (c){
			case 'd':
				debug = 1;
				break;
			case 'e':
				if (prog_specified){
					fprintf (stderr, "multiple -e are not allowed\n");
					clean_and_exit (39);
				}

				prog_specified = optarg;
				break;
			case 'F':
				da_push_dup (&new_argv, "-F");
				da_push_dup (&new_argv, optarg);
				break;
			case 'f':
				add_file (cwd, optarg, 0);
				break;
			case 'h':
				usage ();
				clean_and_exit (0);
				break;
			case 't':
				create_tmpdir = 1;
				break;
			case 'T':
				da_push_dup (&new_argv, "-F");
				da_push_dup (&new_argv, "\t");
				break;
			case 'v':
				da_push_dup (&new_argv, "-v");
				da_push_dup (&new_argv, optarg);
				break;
			case 'V':
				version ();
				clean_and_exit (0);
				break;
			default:
				usage ();
				exit (1);
		}
	}

	argv += optind;
	argc -= optind;

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

		add_file (cwd, *argv, 0);
		progname = *argv;
#if 0
		setprogname (*argv);
		setproctitle (*argv);
#endif
		--argc;
		++argv;
	}

	/* AWK interpreter name */
	if (interp_var)
		interp_var = getenv (interp_var);

	if (interp_var && interp_var [0])
		interp = interp_var;

	/* exec */
	new_argv.array [0] = xstrdup (progname);

	if (includes.size)
		da_push_dup (&new_argv, "--");

	for (i=0; i < (size_t) argc; ++i){
		da_push_dup (&new_argv, argv [i]);
	}

	da_push_dup (&new_argv, NULL);

	putenv_RUNAWK_MODx ();

	/* create temporary directory */
	if (create_tmpdir){
		mktempdir ();
		snprintf (buffer, sizeof (buffer), "_RUNAWK_TMPDIR=%s", temp_dir);
		xputenv (buffer);
	}

	/**/
	if (debug){
		for (i=0; i < new_argv.size - 1; ++i){
			printf ("new_argv [%u] = %s\n", (unsigned) i, new_argv.array [i]);
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
				execvp (interp, (char *const *) new_argv.array);
				fprintf (stderr, "running '%s' failed: %s\n", interp, strerror (errno));
				exit (1);
				break;

			default:
				/* parent */
				waitpid (-1, &child_status, 0);

				da_free_items (&new_argv);
				da_destroy (&new_argv);

				da_free_items (&includes);
				da_destroy (&includes);

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
