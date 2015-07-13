let
  f1 = y: y + 1;
  g1 = z: z * 3;
  comp = g: f: x: f (g x);

  l1 = [ "apples" "bananas" "cantelope" ];
  l2 = [ "artichoke" "broccoli" "cabbage" ];
  l3 = [ "acorn" "beech" "chestnuts" ];
  l4 = [ "amaranth" "barley" "couscous" ];

  inherit (builtins) concatLists;
in
{
  # LISTS
  lists1 = l1 ++ l2 ++ l3 ++ l4;
  lists2 = concatLists [ l1 l2 l3 l4 ];

  # ATTRSETS
  attrsets = {
    a = "apple";
    b = "bananas";
    c = "cantelope";
  } // {
    a = "apricot";
    b = "bacon";
  } // { a = "apfel"; };

  # INTEGERS
  ints1 = 2+5;
  ints2 = 2*10;
  ints3 = 5 / 2;
  ints4 = builtins.add 5 2;
  ints5 = builtins.mul 5 2;
  ints6 = builtins.div 5 2;

  # STRINGS
  strings = "Hello, " + "Casey";

  # FUNCTIONS / LAMBDAS
  h1 = x: f1 (g1 x);
  h2 = x: g1 (f1 x);
  h3 = comp g1 f1; # same results as h1
}
