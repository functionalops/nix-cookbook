let

  inc = x: x + 1;
  dec = x: x - 1;
  doubler = x: 2*x;

  notNull = x: !isNull x;
  onlyNull = isNull;

  values = [ null 0 1 2 3 4 5 6 7 8 9 null ];

  paths = [ /etc/passwd /home /var/run ];

  filterPath = path: type: type != "symlink";

  inherit (builtins) map filter;
in
{
  doubles = map doubler values;
  plusOnes = map inc values;
  minusOnes = map dec values;

  nonNulls = filter notNull values;
  onlyNulls = filter onlyNull values;


}
