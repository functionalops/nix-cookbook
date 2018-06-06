---
layout: post
title: Inspecting Nix lambda function named arguments
---

Some times I get asked how `callPackage` works and then I realize I have failed to teach this person how to better navigate around with Nix expressions and in `nixpkgs` so let's open a `nix repl '<nixpkgs>'` session to explore:

```nix
nix-repl> f = import "${pkgs.path}/pkgs/servers/varnish"

nix-repl> f
«lambda @ /nix/store/8drcpsqry4n2xhai208brjfyhv0s8xzm-a0mjrw6mcpw37sp7yzwkc40kf3718yww-8l2kzla1qx0iksya6pnx5ixm7zc2z49w-nixpkgs-965c944/pkgs/servers/varnish/default.nix:1:1»

nix-repl> builtins.functionArgs f
{ fetchurl = false; groff = false; libedit = false; libxslt = false; makeWrapper = false; ncurses = false; pcre = false; pkgconfig = false; python = false; pythonPackages = false; readline = false; stdenv = false; }
```

`callPackage` uses `builtins.functionArgs` to see what to supply it with from it's current namespace. This is the magic sauce and this is very valuable when exploring the `nixpkgs` Nix expressions.

To finish off understanding `callPackage` though it just intersects attrsets like so:

```nix
nix-repl> builtins.intersectAttrs (builtins.functionArgs f) pkgs
{ fetchurl = «lambda @ /nix/store/a0mjrw6mcpw37sp7yzwkc40kf3718yww-8l2kzla1qx0iksya6pnx5ixm7zc2z49w-nixpkgs-965c944/pkgs/build-support/fetchurl/default.nix:38:1»; groff = «derivation /nix/store/zmv1aadh26njgxr5jwzgzyqwch4vpaz9-groff-1.22.3.drv»; libedit = «derivation /nix/store/znngmjzm7cb3vcli6574kvfwv2v05qk4-libedit-20160903-3.1.drv»; libxslt = «derivation /nix/store/l7ydwp52j6rq75zr9bh4x69lc8f8w3i3-libxslt-1.1.29.drv»; makeWrapper = «derivation /nix/store/ml1arp76zl0p1khfn1d3bj9s2mbbfsnz-hook.drv»; ncurses = «derivation /nix/store/dis752dbllygrjb8ql4fwdzxm4l7mzy0-ncurses-6.0-20171125.drv»; pcre = «derivation /nix/store/56v16nr7llsphz4v9p86d6hc74f48gml-pcre-8.41.drv»; pkgconfig = «derivation /nix/store/0iv24kmnrf7x56jk03hz9qs0fhzkkl5w-pkg-config-0.29.2.drv»; python = «derivation /nix/store/c0la0fgiq55j801mrda90vhjjapjr8jh-python-2.7.14.drv»; pythonPackages = { ... }; readline = «derivation /nix/store/nk9kflnhpgxqzsdkyxmwcs4sg9ac44wf-readline-6.3p08.drv»; stdenv = «derivation /nix/store/i8nz0gpadq8khdcrimjagmragkdxld00-stdenv.drv»; }
```

So next time you are interested in what named arguments a Nix lambda takes then use `builtins.functionArgs`.
