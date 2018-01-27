---
layout: post
title: Aspell with custom dictionaries configured
---

This quick post describes how to configure your `aspell` dictionaries.
This might be needed for your development environment or it could be
required for production systems to operate properly. One development
need I have is to configure dictionaries for the `aspell` package
for `flyspell` to work in my new emacs/spacemacs configuration (formerly
my local vim configuration).

We can accomplish this in several ways:

* configure this at the system level
* configure this at the user level
* have our shell rc scripts set the `ASPELL_CONF` environment variable
  to the appropriate path for the `dict-dir` attribute.

On my development NixOS I chose to configure this in my user profile. If
a production server required this I would chose the first approach (system level
configuration) in my Nix expression for the system.

The rationale for the user level of Nix customization for development environments
is because I like to reduce the scope of the system configuration on my laptops/tablets.
I will typically only have one user account on these devices so I will not gain much
by providing modern conveniences at the system-level, plus I can `scp` my user Nix
expression to remote development environments to make my development experience
portable, distributable, and reproducible with minimal effort.

## User-level Nix Setup of `aspell` dictionaries

Since I care about the reproducibility of my development environment a great deal
(hey, shit happens, even if the Universe has not killed my hard drive recently, I
expect over time that will change) I have a user-level Nix expression under the path
`${HOME}/.config/nixpkgs/config.nix`. Nix/NixOS allows you to override/overlay your
own configuration on top of the default `nixpkgs`/`nixos` channels in a variety of
ways:

* using package overrides (old fashioned at this point given we have overlays)
* using overlays (introduced in 17.09, I think; relatively new)

Note: the user Nix expression used to be located/expected at `${HOME}/.nixpkgs/config.nix`.

I am not going to share the entirety of my own user Nix expression inline here
but my user Nix expression looks something like the following:

```nix
{ pkgs }:
let
  inherit (pkgs) aspellWithDicts; # among other inherits

  # setup custom vim and emacs/spacemacs configuration using Nix helpers already in nixpkgs

  # Now the custom aspell with custom dictionary set configured
  myaspell = aspellWithDicts (d: [d.en]);
  # Yes, I am a grotesque monolinguist, but you can put whatever dictionaries aspell offers in the list returned in the
  # lambda provided to `aspellWithDicts`.
in {
  allowUnfree = true;

  # some firefox and chromium attribute settings here that you probably don't care about, etc.

  # This is the old method of package overriding which I haven't yet converted to overlays, I know CURMUDGEON!
  packagesOverrides = pkgs: rec {
    myDevenv = buildEnv {
      name = "my-devenv";
      paths = with pkgs; [
        mtr
        tcpdump
        inetutils

        # lots of other things and then
        myaspell
      ];
    };
  };
}
```

Now let's test this in our user environment/profile:

```
$ nix-env -i myaspell
... redacted spurious output not relevant to our testing ...

$ env | grep ASPELL
ASPELL_CONF=dict-dir /home/myusername/.nix-profile/lib/aspell

$ ls "$(readlink -f ~/.nix-profile/lib/aspell)/en_US*"
/nix/store/abcdef0123456789...-aspell-env/lib/aspell/en_US.multi
/nix/store/abcdef0123456789...-aspell-env/lib/aspell/en_US-variant_0.multi
...other entried redacted for space considerations
/nix/store/abcdef0123456789...-aspell-env/lib/aspell/en_US-wo_accents-only.rws

$ aspell list <<<"some words one of which will be mispelledk"
mispelledk

```

[Overlays](https://nixos.org/nixpkgs/manual/#chap-overlays) are recommended in recent versions of `nixpkgs` and above.

Cheers, until next time.
