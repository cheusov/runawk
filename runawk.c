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
  -i|--with-stdin     always add \"stdin\" file name to awk arguments\n\
  -I|--without-stdin  do not add \"stdin\" file name to awk arguments\n\
  -e|--execute <program>  program to run\n\
  -v|--assign <var=val>   assign the value val to the variable var\n\
");
}

static const char *runawk_version = RUNAWK_VERSION;

static void version (void)
{
	printf ("runawk %s written by Aleksey Cheusov\n", runawk_version);
}

static char *includes [ARRAY_SZ];
static int includes_count = 0;

static char *awkpath      = NULL;
static size_t awkpath_len = 0;

static char cwd [PATH_MAX];

static const char *interp     = AWK_PROG;
static const char *sys_awkdir = MODULESDIR;

static int debug = 0;

typedef enum {stdin_default, stdin_yes, stdin_no} add_stdin_t;
static add_stdin_t add_stdin  = stdin_default;

static char *new_argv [ARRAY_SZ];
static int new_argc = 0;

static void clean_and_exit (int status)
{
	if (awkpath)
		free (awkpath);

	exit (status);
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

	/* AWKPATH env. */
	for (i = 0; i < awkpath_len; ++i){
		if (awkpath [i] && (i == 0 || awkpath [i-1] == 0)){
			curr_dir = awkpath + i;
			snprintf (buf, sizeof (buf), "%s/%s", curr_dir, name);
			if (!access (buf, R_OK)){
				return xstrdup (buf);
			}
		}
	}

	/* system directory for modules */
	snprintf (buf, sizeof (buf), "%s/%s", sys_awkdir, name);
	if (!access (buf, R_OK)){
		return xstrdup (buf);
	}

	return NULL;
}

static void invalid_use_directive (int num, char *line, const char *fn)
{
	char * nl = strchr (line, '\n');
	if (nl)
		*nl = 0;

	fprintf (stderr,
			 "error: invalid directive at line #%d,\n line=`%s`\n file=`%s`\n",
			 num, line, fn);
}

static void add_file_uniq (const char *dir, const char *name);

static char *extract_qstring (
	char *line, int line_num, const char *fn, char *s)
{
	char *p = NULL;
	char *n = NULL;

	p = s + strspn (s, " \t");
	if (*p != '"'){
		invalid_use_directive (line_num, line, fn);
		clean_and_exit (37);
	}

	++p;

	n = strpbrk (p, "\"\n");
	if (!n || *n == '\n'){
		invalid_use_directive (line_num, line, fn);
		clean_and_exit (37);
	}

	*n = 0;
	return xstrdup (p);
}

static void scan_buffer (
	const char *name, const char *dir,
	char *buffer, off_t sz)
{
	char *env_str = NULL;
	char *p = buffer;
	int line_num = 0;

	for (; sz--; ++p){
		if (p != buffer && p [-1] != '\n')
			continue;

		++line_num;

		if (!strncmp (p, "#use ", 5)){
			add_file_uniq (dir, extract_qstring (p, line_num, name, p + 5));
		}
		if (!strncmp (p, "#interp ", 8)){
			interp = extract_qstring (p, line_num, name, p + 8);
		}
		if (!strncmp (p, "#env ", 5)){
			env_str = (char *) extract_qstring (p, line_num, name, p + 5);
			xputenv (env_str);
			free (env_str);
		}
	}
}

static void scan_file (const char *name)
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
		perror ("stat(2) failed");
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

	scan_buffer (name, dir, buffer, file_size);

	free (buffer);

	if (fclose (fd)){
		perror ("fclose(3) failed");
		clean_and_exit (36);
	}
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

static void add_buffer (char *buffer)
{
	/* recursive snanning for #xxx directives */
	scan_buffer ("", "-", buffer, strlen (buffer));

	/* add to queue */
	ll_push (buffer, new_argv, &new_argc);
}

static void add_file (const char *dir, const char *name)
{
	const char *new_name = NULL;

	if (name [0] != '/'){
		/* name -> path */
		new_name = search_file (dir, name);
		if (!new_name){
			fprintf (stderr, "Cannot find file `%s`, check AWKPATH environment variable\n", name);
			clean_and_exit (34);
		}
		name = new_name;
	}

	/* recursive snanning for #xxx directives */
	scan_file (name);

	/* add to queue */
	ll_push ("-f", new_argv, &new_argc);
	ll_push (name, new_argv, &new_argc);
	ll_push (name, includes, &includes_count);
}

static void add_file_uniq (const char *dir, const char *name)
{
	int i;
	const char *p;
	const char *inc;

	for (i=0; i < includes_count; ++i){
		inc = includes [i];
		p = strstr (inc, name);

		if (p && (p == inc || (p [-1] == '/' && p [strlen (p)] == 0))){
			return;
		}
	}

	add_file (dir, name);
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
			add_stdin = stdin_yes;
			break;
		case 'I':
			add_stdin = stdin_no;
			break;
		default:
			abort ();
	}
}

int main (int argc, char **argv)
{
	const char *progname   = NULL;
	pid_t pid              = 0;
	int child_status       = 0;
	int all_with_dash      = 1;
	const char *p          = NULL;
	const char *env_interp = getenv ("RUNAWK_AWKPROG");
	int prog_specified     = 0;

	int i;

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
	awkpath = getenv ("AWKPATH");
	if (awkpath){
		awkpath = xstrdup (awkpath);

		awkpath_len = strlen (awkpath);
		for (i=0; i < awkpath_len; ++i){
			if (awkpath [i] == ':'){
				awkpath [i] = 0;
			}
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
		if (!strcmp (argv [0], "--assign") || !strcmp (argv [0], "-v")){
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

		/* -e */
		if (!strcmp (argv [0], "-e") || !strcmp (argv [0], "--execute")){
			if (argc == 1){
				fprintf (stderr, "missing argument for -e option\n");
				clean_and_exit (39);
			}

			add_buffer (argv [1]);

			prog_specified = 1;

			--argc;
			++argv;
			continue;
		}

		/* -h -V -d -i -I etc. */
		for (p = argv [0]+1; *p; ++p){
			switch (*p){
				case 'h':
				case 'V':
				case 'd':
				case 'i':
				case 'I':
					process_opt (*p);
					break;
				default:
					fprintf (stderr, "unknown option -%c\n", *p);
					clean_and_exit (1);
			}
		}
	}

	progname = interp;
	if (!prog_specified){
		/* program_file */
		if (argc < 1){
			usage ();
			clean_and_exit (30);
		}

		--argc;
		add_file (cwd, *argv);
		progname = *argv;
#if 0
		setprogname (*argv);
		setproctitle (*argv);
#endif
		++argv;
	}

	/* exec */
	new_argv [0] = xstrdup (progname);

	ll_push ("--", new_argv, &new_argc);

	for (i=0; i < argc; ++i){
		if (argv [i][0] != '-'){
			all_with_dash = 0;
		}

		ll_push (argv [i], new_argv, &new_argc);
	}

	if (add_stdin == stdin_yes ||
		(argc && all_with_dash && add_stdin != stdin_no))
	{
		ll_push (STDIN_FILENAME, new_argv, &new_argc);
	}

	ll_push (NULL, new_argv, &new_argc);

	if (debug){
		for (i=0; i < new_argc - 1; ++i){
			printf ("new_argv [%d] = %s\n", i, new_argv [i]);
		}
	}else{
		pid = fork ();
		switch (pid){
			case -1:
				perror ("fork(2) failed");
				clean_and_exit (42);
				break;

			case 0:
				execvp (interp, (char *const *) new_argv);
				perror ("execvp(2) failed");
				exit (1);
				break;

			default:
				waitpid (-1, &child_status, 0);
				if (WIFSIGNALED (child_status))
					clean_and_exit(128 + WTERMSIG (child_status));
				else if (WIFEXITED (child_status))
					clean_and_exit (WEXITSTATUS (child_status));
				else
					clean_and_exit (200);
		}
	}

	clean_and_exit (0);
	return 0; /* this should not happen but fixes gcc warning */
}
