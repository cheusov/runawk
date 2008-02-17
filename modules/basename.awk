# written by Aleksey Cheusov <vle@gmx.net>
# public domain

# basename -- return filename portion of pathname
function basename (pathname){
	sub(/^.*\//, "", pathname)
	return pathname
}
