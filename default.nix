let
  basicsExercises = builtins.trace "Importing basics exercises" import ./basics;
in
{
  basics = basicsExercises;
}
