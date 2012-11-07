/*
 * Copyright (c) 2012 Aleksey Cheusov <vle@gmx.net>
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

#include <stdio.h>
#include <dirent.h>
#include <limits.h>
#include <string.h>
#include <sys/stat.h>
#include <errno.h>

#include "file_hier.h"

#if HAVE_FUNC3_STRLCPY
size_t strlcpy(char *dst, const char *src, size_t size);
#endif

#if HAVE_FUNC3_STRLCAT
size_t strlcat(char *dst, const char *src, size_t size);
#endif

void file_hier (
	const char *dir,
	void (*proc_file) (const char *fn),
	void (*proc_dir) (const char *fn))
{
	char buffer [PATH_MAX];
	size_t dir_len = strlen (dir)+1;
	struct stat sb;
	struct dirent *dp;
	DIR *dirp;

	if (dir_len+1 > sizeof (buffer)){
		return;
	}

	dirp = opendir(dir);
	if (dirp != NULL) {
		strlcpy (buffer, dir, sizeof (buffer));
		strlcat (buffer, "/", sizeof (buffer));

		while (dp = readdir(dirp), dp != NULL){
			if (dp->d_name [0] == '.'){
				if (dp->d_name [1] == 0 ||
					(dp->d_name [1] == '.' && dp->d_name [2] == 0))
				{
					/* ignore . and .. */
					continue;
				}
			}

			buffer [dir_len] = 0;
			strlcat (buffer, dp->d_name, sizeof (buffer));
			if (0 == lstat (buffer, &sb)){
				if (S_ISDIR (sb.st_mode)){
					file_hier (buffer, proc_file, proc_dir);
				}else{
					proc_file (buffer);
				}
			}else{
				fprintf (stderr, "stat(\"%s\") failed: %s\n", buffer, strerror (errno));
			}
		}

		closedir (dirp);

		proc_dir (dir);
	}else{
		fprintf (stderr, "opendir(\"%s\") failed: %s\n", dir, strerror (errno));
	}
}
