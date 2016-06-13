---
layout: post
title: Nix if-then-else expressions
---

## Nix if-then-else expressions

A coworker asked the following question:

> I understand how to use an if/else, but I don’t understand how to get an
> if/elseif/else.

Below is my Slack response (slightly edited) to explain the dissonance in the
question itself and then provide a path forward for him. I imagine this might
be a common misunderstanding for those coming to Nix without prior understanding
of expression languages vs languages that use statements.

Nix being an expression language just has expressions (where the result of
each part evaluates to a value [eventually]). Most mainstream imperative
languages like Perl, Bash, etc. that most people are familiar with use this
notion of statements statements rather than expressions. Statements allow
these languages to support if/elseif/.../else as an extension.

In Nix and other expression based languages, this is not the case and a
limiting factor of expressions is that every expression must evaluate to a
value. So you might write:

```nix
{
  key = if builtins.pathExists ./path then "woot" else "bummer";
}
```

In the case the `./path` exists it will evaluate to the value `"woot"`
otherwise it evaluates to the value `"bummer"`.

So the result of the top level expression is:

```nix
{ key = "woot"; }

# OR

{ key = "bummer"; }
```

This does not translate to languages that model `if`s as statements, for
example:

```bash
$ declare bla=$(if true; then "bla"; else "foo"; fi)
$ echo "${bla}"

$ declare bla=$(if true; then echo "bla"; else echo "foo"; fi)
$ echo "${bla}"
bla
```

Note: that side effects are _required_ inside each clause.

Looking at the equivalent `if/else` statement for the expression example
above we have:

```bash
if [ -f ./path ]; then
  declare key="woot"
else
  declare key="bummer"
fi
```

Here you see that Bash uses side effects to do the assignment in each case,
but say we had this:

```nix
if [ -d ./path ]; then
  declare key="woot"
elseif [ -x ./path ]; then
  echo "executable"
else
  declare key="bummer"
fi
```

Now we have a case (where the file is not a directory *and* also executable)
that the variable key is not set. This wouldn't happen in an expression based
language.

In short `if-then-else` is the only way we can build an expression to always
evaluate to a value where all logical paths are covered _without_ the program
needing to know about the underlying data or condition clauses inspected in
the if portion.

You can think of `if-then-else` as a lambda that is defined as:

```nix
  ifThenElse = cond: t: f: if cond then t else f
```

So to solve the problem you take one of two approaches.

* If your use case is matching strings exactly in each `if/ifelse` condition,
then you can use an attrset with the keys as the values you need to match:

```nix
{ envType, defaultCfg }:
let
  cases = { "dev" = devCfg; "test" = testCfg; "prod" = prodCfg; };
  lookup = attrs: key: default:
    if attrs ? key then attrs."${key}" else default;
in lookup environments envType defaultCfg
```

* Use nested `if-then-else` expressions when you cannot just lookup a key
   in an attrset.

