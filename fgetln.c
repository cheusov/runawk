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

char *
my_fgetln(FILE *fp, size_t *len)
{
	static char buf [4096];

	if (fgets (buf, sizeof (buf), fp)){
		*len = strlen (buf);
		if (buf [*len-1] == '\n'){
			--*len;
			buf [*len] = 0;
		}
		return buf;
	}else{
		return NULL;
	}
}

#define fgetln my_fgetln
