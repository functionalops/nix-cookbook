---
layout: post
title: Nix Basics
---

## Nix Cookbook

[This repository]({{ site.github.repo }}) is a collection of Nix expressions
and snippets that show you how you can get common tasks done in Nix.

The target audience are those that have read the
[Nix Manual](http://nixos.org/nix/manual/) and found it great reference
material but need more examples to be more productive with the following
toolset:

* [Nix](http://nixos.org/nix/)
* [NixOS](http://nixos.org/nixos/)
* [NixOps](http://nixos.org/nixops/)

### Prerequisites

I recommend Nix 1.9+ (although most exercises should work in 1.8) and
installing `nix-repl`:

```bash
$ nix-env -i nix-repl
```

Alternatively just start the `nix-shell` at the root of this repository:

```bash
$ nix-shell
```

### Basics

To get started doing warmups the following snippets provide examples and
exercises to get acquainted with the different builtin types in the Nix
expression language.

Start by using the `nix-repl`.

* [Integers]({{ site.github.repo }}/tree/master/basics/integers.nix)
* [Booleans]({{ site.github.repo }}/tree/master/basics/booleans.nix)
* [Strings]({{ site.github.repo }}/tree/master/basics/strings.nix)
* [Paths]({{ site.github.repo }}/tree/master/basics/paths.nix)
* [Files]({{ site.github.repo }}/tree/master/basics/files.nix)
* [Lists]({{ site.github.repo }}/tree/master/basics/lists.nix)
* [Attrsets]({{ site.github.repo }}/tree/master/basics/attrsets.nix)
* [Lambdas]({{ site.github.repo }}/tree/master/basics/lambdas.nix)
* [Concatenation]({{ site.github.repo }}/tree/master/basics/concatenation.nix)
* [Importing]({{ site.github.repo }}/tree/master/basics/importing.nix)

Poke around at the examples and let me know (via
[pull requests]({{ site.github.repo }}/pulls) or
[issues]({{ site.github.repo }}/issues))
about any problems or suggestions you have for the material.
