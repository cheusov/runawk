/*
 * Copyright (c) 2011-2014 Aleksey Cheusov <vle@gmx.net>
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

#include <stdlib.h>
#include <string.h>

#include "common.h"

#include "dynarray.h"

void da_init (dynarray_t * array)
{
	array->size      = 0;
	array->allocated = 0;
	array->array     = NULL;
}

void da_push (dynarray_t * array, char *item)
{
	if (array->allocated == array->size){
		array->allocated = array->allocated * 4 / 3 + 100;
		array->array = realloc (
			array->array, array->allocated * sizeof (*array->array));
	}

	array->array [array->size++] = item;
}

void da_push_dup (dynarray_t * array, const char *item)
{
	char *dup = (item ? strdup (item) : NULL);
	da_push (array, dup);
}

void da_free_items (dynarray_t * array)
{
	size_t i;
	for (i=0; i < array->size; ++i){
		if (array->array [i]){
			free ((void *) array->array [i]);
			array->array [i] = NULL;
		}
	}
}

void da_destroy (dynarray_t * array)
{
	if (array->array)
		free (array->array);
	array->array     = NULL;
	array->size      = 0;
	array->allocated = 0;
}
