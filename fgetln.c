/*
 * Copyright (c) 2006 Aleksey Cheusov
 *
 * This material is provided "as is", with absolutely no warranty
 * expressed or implied. Any use is at your own risk.
 *
 * Permission to use or copy this software for any purpose is hereby
 * granted without fee, provided the above notices are retained on all
 * copies.  Permission to modify the code and to distribute modified
 * code is granted, provided the above notices are retained, and a
 * notice that the code was modified is included with the above
 * copyright notice.
 *
 */

char *
fgetln(FILE *fp, size_t *len)
{
	static char buf [4096];

	if (fgets (buf, sizeof (buf), fp)){
		*len = strlen (buf);
		return buf;
	}else{
		return NULL;
	}
}
