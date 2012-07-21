#env "LC_ALL=C"
#env "FOO=BAR"

BEGIN {
   print ("y" ~ /^[a-z]$/)
   print ("Y" ~ /^[a-z]$/)
   print ("z" ~ /^[a-z]$/)
   print ("Z" ~ /^[a-z]$/)

   print ("env FOO=" ENVIRON ["FOO"])
   print ("env TESTVAR=" ENVIRON ["TESTVAR"])
}
