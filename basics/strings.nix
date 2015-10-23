let
  inherit (builtins) substring stringLength;
in
{
  subStr1 = substring 0 5 "123456"; # => "12345"
  subStr2 = substring 2 3 "123456"; # => "345"

  len1 = stringLength "Hello world."; # => 12
  len2 = stringLength "yo yo"; # => 5


}
