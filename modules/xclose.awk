# written by Aleksey Cheusov <vle@gmx.net>
# public domain

# xclose(FILE) -- safe wrapper for 'close', returned value is analysed

#use "alt_assert.awk"

function xclose (fn){
	assert(close(fn) == 0, "close(\"" fn "\") failed")
}
