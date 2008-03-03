# written by Aleksey Cheusov <vle@gmx.net>
# public domain

# xsystem(FILE) -- safe wrapper for 'system', returned value is analysed

#use "alt_assert.awk"

function xsystem (fn){
	assert(system(fn) == 0, "system(\"" fn "\") failed")
}
