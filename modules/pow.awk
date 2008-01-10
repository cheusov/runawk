# written by Aleksey Cheusov <vle@gmx.net>
# public domain

# abs -- the value of x to the exponent y
function pow (x, y){
	return exp(y * log(x))
}
