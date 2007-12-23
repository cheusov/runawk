/*
 * Copyright (c) 2007, Aleksey Cheusov <vle@gmx.net>
 *
 * Permission to use, copy, modify, distribute and sell this software
 * and its documentation for any purpose is hereby granted without
 * fee, provided that the above copyright notice appear in all copies
 * and that both that copyright notice and this permission notice
 * appear in supporting documentation.  I make no
 * representations about the suitability of this software for any
 * purpose.  It is provided "as is" without express or implied
 * warranty.
 *
 */

#include <sys/types.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <limits.h>

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

#ifndef HAVE_WGETLN
#if !defined(__NetBSD__) && !defined(__FreeBSD__) && !defined(__OpenBSD__) && !defined(__DragonFlyBSD__) && !defined(__INTERIX)
#include "fgetln.c"
#endif
#endif

static void usage (void)
{
	puts ("\
runawk - wrapper for the AWK interpreter\n\
usage: runawk [OPTIONS] program_file [arguments...]\n\
OPTIONS:\n\
  -h    display this screen\n\
  -V    display version information\n\
  -d    debugging mode, just list new argv array, do not run interpreter\n\
  -i    always add \"stdin\" file name to a list of awk arguments\n\
  -I    do not add \"stdin\" file name to a list of awk arguments\n\
\n\
README file in a distribution contains the documentation\n\
");
}

static const char *runawk_version = "0.8.1";

static void version (void)
{
	printf ("runawk %s written by Aleksey Cheusov\n", runawk_version);
}

static const char *includes [ARRAY_SZ];
static int includes_count = 0;

static const char *temp_files [ARRAY_SZ];
static int temp_files_count = 0;

static char *awkpath      = NULL;
static size_t awkpath_len = 0;

void remove_tmp_files ()
{
	int i;
	for (i=0; i < temp_files_count; ++i){
		unlink (temp_files [i]);
	}
}

void clean_and_exit (int status)
{
	remove_tmp_files ();

	if (awkpath)
		free (awkpath);

	exit (status);
}

static char cwd [PATH_MAX];

static const char *interp = AWK_PROG;
static int line_num = 0;

static const char *search_file (const char *dir, const char *name)
{
	/* search in AWKPATH env. */
	const char *curr_dir = NULL;
	char buf [PATH_MAX];
	size_t i;

	/* dir argument */
	snprintf (buf, sizeof (buf), "%s/%s", dir, name);
	if (!access (buf, R_OK)){
		return strdup (buf);
	}

	/* AWKPATH env. */
	for (i = 0; i < awkpath_len; ++i){
		if (awkpath [i] && (i == 0 || awkpath [i-1] == 0)){
			curr_dir = awkpath + i;
			snprintf (buf, sizeof (buf), "%s/%s", curr_dir, name);
			if (!access (buf, R_OK)){
				return strdup (buf);
			}
		}
	}

	return NULL;
}

static void invalid_use_directive (int num, const char *line, const char *fn)
{
	fprintf (stderr,
			 "error: invalid directive at line #%d,\n line=`%s`\n file=`%s`\n",
			 num, line, fn);
}

static void push_uniq (const char *dir, const char *name);

static const char *extract_qstring (char *line, const char *fn, char *s)
{
	char *p = NULL;
	char *n = NULL;

	p = strchr (s, '"');
	if (p)
		n = strchr (p + 1, '"');

	if (!p || !n){
		invalid_use_directive (0, line, fn);
		clean_and_exit (37);
	}

	*n = 0;
	return strdup (p+1);
}

static void scan_for_use (const char *name)
{
	char dir [PATH_MAX];
	char *line = NULL;
	size_t len = 0;
	FILE *fd = NULL;

	len = strlen (name);
	strncpy (dir, name, sizeof (dir));
	while (len--){
		if (dir [len] == '/'){
			dir [len] = 0;
			break;
		}
	}

	fd = fopen (name, "r");
	if (!fd){
		fprintf (stderr, "fopen(%s) failed: %s\n", name, strerror (errno));
		clean_and_exit (35);
	}

	line_num = 0;
	while (line = fgetln (fd, &len), line != NULL){
		++line_num;

		if (line [len-1] == '\n')
			line [len-1] = 0;

		if (!strncmp (line, "#use ", 5)){
			push_uniq (dir, extract_qstring (line, name, line + 5));
		}
		if (!strncmp (line, "#interp ", 5)){
			interp = extract_qstring (line, name, line + 8);
		}
	}
	if (ferror (fd)){
		perror ("fgetln(3) failed");
		clean_and_exit (36);
	}
}

static void ll_push (
	const char *item,
	const char **array,
	int *array_size)
{
	if (*array_size == ARRAY_SZ){
		fprintf (stderr, "too big array\n");
		clean_and_exit (31);
	}

	array [*array_size] = item;
	++*array_size;
}

static void push (const char *dir, const char *name)
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

	/* recursive snanning for #use directive */
	scan_for_use (name);

	/* add to queue */
	ll_push (name, includes, &includes_count);
}

static void push_uniq (const char *dir, const char *name)
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
	push (dir, name);
}

static const char *get_tmp_name ()
{
	char tmp_name [PATH_MAX];
	static int intern_count = 0;
	char *dup = NULL;

	snprintf (tmp_name, sizeof (tmp_name),
			  "/tmp/runawk.%d.%d",
			  (int) getpid (), intern_count);

	++intern_count;

	dup = strdup (tmp_name);
	if (!dup){
		perror ("strdup(3) failed");
		clean_and_exit (38);
	}

	ll_push (dup, temp_files, &temp_files_count);

	return dup;
}

typedef enum {stdin_default, stdin_yes, stdin_no} add_stdin_t;

int main (int argc, char **argv)
{
	const char *new_argv [ARRAY_SZ];
	const char *tmp_name   = NULL;
	const char *progname   = NULL;
	int new_argc           = 0;
	int debug              = 0;
	FILE *fd               = NULL;
	pid_t pid              = 0;
	int child_status       = 0;
	int all_with_dash      = 1;
	add_stdin_t add_stdin = stdin_default;
	int i;
	int not_e              = 0;

	--argc, ++argv;

	if (argc == 0){
		usage ();
		return 30;
	}

	/* AWKPATH env. */
	awkpath = getenv ("AWKPATH");
	if (awkpath){
		awkpath = strdup (awkpath);
		if (!awkpath){
			perror ("strdup failed");
			clean_and_exit (33);
		}

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

	/* options, no getopt(3) here */
	if (argc && argv [0][0] == '-'){
		if (strchr (argv [0], 'h')){
			usage ();
			clean_and_exit (0);
		}
		if (strchr (argv [0], 'V')){
			version ();
			clean_and_exit (0);
		}
		if (strchr (argv [0], 'd')){
			debug = 1;
			not_e = 1;
		}
		if (strchr (argv [0], 'i')){
			add_stdin = stdin_yes;
			not_e     = 1;
		}
		if (strchr (argv [0], 'I')){
			add_stdin = stdin_no;
			not_e     = 1;
		}

		if (not_e){
			--argc;
			++argv;
		}
	}

	/* -e options */
	while (argc && !strcmp (argv [0], "-e")){
		if (argc == 1){
			fprintf (stderr, "missing argument for -e option");
			clean_and_exit (39);
		}

		tmp_name = get_tmp_name ();
		fd = fopen (tmp_name, "w");
		if (!fd){
			perror ("fopen(3) failed");
			clean_and_exit (40);
		}
		fputs (argv [1], fd);
		fputs ("\n", fd);
		if (fclose (fd)){
			perror ("fclose(3) failed");
			clean_and_exit (41);
		}

		push ("", tmp_name);

		argc -= 2;
		argv += 2;
	}

	progname = interp;
	if (!includes_count){
		/* program_file */
		if (argc < 1){
			usage ();
			clean_and_exit (30);
		}

		--argc;
		push (cwd, *argv);
		progname = *argv;
#if 0
		setprogname (*argv);
		setproctitle (*argv);
#endif
		++argv;
	}

	/* exec */
	ll_push (progname, new_argv, &new_argc);
	for (i=0; i < includes_count; ++i){
		ll_push ("-f",         new_argv, &new_argc);
		ll_push (includes [i], new_argv, &new_argc);
	}

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
			fprintf (stderr, "new_argv [%d] = %s\n", i, new_argv [i]);
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
				clean_and_exit (WEXITSTATUS (child_status));
		}
	}

	exit (0);
}
