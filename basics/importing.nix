let

  # importing a list into a binding
  services = import ./services.nix;

  # importing a function into a binding
  userF = import ./user.nix;

  # importing an attrset into a binding
  usersInfo = import ./users.nix;

  usernames = attrNames usersInfo;

  # Start uids at 2000. Why not?
  startUid = 2000;

  userCount = length usernames;

  inc = i: i + 1;
  dec = i: i - 1;
  append = x: xs: xs ++ [x];

  mkRange = start: count:
    let
      mkRangeAcc = next: len: acc:
        if len > 0
        then mkRangeAcc (inc next) (dec len) (append next acc)
        else append next acc;
    in
      mkRangeAcc (inc start) (dec count) (append start []);

  zipWith = op: xs: ys:
    let
      funs = map op xs;
      zipAcc = funs: zs: acc:
        if length funs > 0 && length zs > 0
        then zipAcc (tail funs) (tail zs) (acc ++ [((head funs) (head zs))])
        else acc;
    in
      zipAcc funs ys [];

  inherit (builtins) map attrNames length tail head;
in
{
  services = services;
  mkRange = mkRange;
  zipWith = zipWith;
  users = usersInfo;
}
