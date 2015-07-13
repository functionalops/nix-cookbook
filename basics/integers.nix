# Load this file with: `nix-repl basics.nix`
# Then inspect the values of the evaluated attrset.
let
  inherit (builtins) add mul div sub isInt;
in
{
  timeoutSecs = 30;
  timeoutMs = 30*1000;

  subtracting1 = 60 - 50;
  multiplying1 = 60 * 5;
  adding1 = 60 + 50;
  dividing1 = 60 / 7;

  subtracting2 = sub 60 50;
  multiplying2 = mul 60 5;
  adding2 = add 60 50;
  dividing2 = div 60 7;

  # try `:t hopefullyFloat1` in the REPL and see what type is returned :)
  hopefullyFloat1 = 123/100;
  # try `:t hopefullyFloat2` in the REPL and see what type is returned (and it's value).
  hopefullyFloat2 = 123 / 100;

  # There are no floats in Nix.

  is3Int = isInt 3; # => true
  isStrInt = isInt ""; # => false
  isNullInt = isInt null; # => false
}
