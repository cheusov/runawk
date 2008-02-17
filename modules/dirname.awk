# written by Aleksey Cheusov <vle@gmx.net>
# public domain

# dirname -- return filename portion of pathname
function dirname (pathname){
	if (sub(/\/[^\/]*$/, "", pathname))
		return pathname
	else
		return "."
}
