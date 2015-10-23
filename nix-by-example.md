---
layout: page
title: Nix By Example
---

## Terminology Mapping

Command mapping:

* `debuild`   => `nix-build`
* `dpkg`      => `nix-build`
* `aptitude`  => `nix-env`
* `apt-cache` => `nix-store`

Concept mapping:

* DEB package definition => Nix expression
* APT source => Nix channel
* APT repository => Nix binary cache

## Nix Packaging: Channels

Channels are like yum/apt repositories, but ... you have to define the
revision you point to whether explicitly or implicitly (symlinks, or 30x
redirects). Prefer explicit _pinning_ of channel revisions.

## Nix Packaging: `<nixpkgs>`

Central Nix community package channel (installed by default).

https://github.com/NixOS/nixpkgs

## Nix Packaging: `nix-channel`

```bash
# Add named channel by URL
$ nix-channel --add URL [NAME]

# Remove named channel
$ nix-channel --remove NAME

# Update optionally named channel (or all if no name given)
$ nix-channel --update [NAME]
```

## Nix Packaging: Binary Caches

Due to property of Nix packages having a SHA calculated by all package
inputs that may change the resulting binary (e.g. source URL, version,
build steps, exact dependencies resolved at build time, compiler flags,
etc.) we get can do actual binary substitution without loss of reasoning.

## Nix Packaging: Derivation

```nix
{ stdenv, fetchurl, kerli, tar }:

stdenv.mkDerivation {
  name = "loveisdead-2.1.1";
  buildInputs = [ kerli tar ];

  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup
    PATH=$kerli/bin:$tar/bin:$PATH
    tar xvfz $src; cd loveisdead-*
    ./configure --prefix=$out && make && make install
  '';

  src = fetchurl {
    url = http://ker.li/dist/tarballs/loveisdead-2.1.1.tar.gz;
    sha256 = "79aac81d987fe7e3aadefc70394564fefe189351";
  };
}
```

## Nix Packaging: Structure #1

```
z/etc/pkg
├── blabla-server/
|   └── default.nix
└── blabla-cache/
    └── default.nix

2 directory, 2 files
```

*Source:* A Subdirectory for each component inside your `z/` directory in the
service repository.

## Nix Packaging: Structure #2

```nix
{ pkgs ? import <nixpkgs> {}
, artifactVersion ? "2.0.75+234235"
, artifactSha256 ? "543f9a54346c626edd172c3dfe06b608739f814f76bbfd235ef2fdd17694bfa4"
}:
let

  inherit (pkgs) stdenv bash oraclejdk8 coreutils procps;
  version = artifactVersion;
  serviceName = "blabla";
  componentName = "${serviceName}-server";

in
{
  "${componentName}" = stdenv.mkDerivation {
    name = serviceName;
    version = version;

    buildInputs = [ oraclejdk8 coreutils procps bash ];
    src = fetchurl {
      url = "https://download.artifactserver.com/${componentName}/${artifactVersion}.jar";
      sha256 = artifactSha256;
    };
    buildCommand = ''
      source ${stdenv}/setup
      mkdir -p $out/lib $out/bin $out/etc
      # OTHER STUFF HERE
    '';
  };
}
```

## Nix Expressions: Tools

Nix 1.9+ includes:

* `nix-build`
* `nix-env`
* `nix-shell`
* `nix-instantiate`

Not included (`nix-repl` for Nix 1.9):

```bash
$ nix-install-package --non-interactive \
  --url http://hydra.nixos.org/build/23321272/nix/pkg/nix-repl-1.9-45c6405-x86_64-linux.nixpkg
```

## Nix Expressions: Environment #1

* `NIX_PATH` - colon-separated paths which can include *named* key-value list, e.g.:
** "`/nix/var/nix/profiles/per-user/root/channels:`*nixpkgs=*`${MY_NIX_BASE}/nixpkgs:...`"
* `ls -F /nix/var/nix/profiles/per-user/root/channels`
** `binary-caches/ mychannel@ manifest.nix@  nixos@`
* Now we can do: `nix-instantiate --eval '<mychannel>'`
* Yielding _lazy_ result: `<LAMBDA>`
* It needs an argument:
** `nix-instantiate --eval '<mychannel>' --arg nixpkgs '<nixpkgs>'`
* Again yielding lazy evaluation result, this time:
** `{ jruby1_7 = <CODE>; jruby1_7_20 = <CODE>; jruby1_7_20_1 = <CODE>; jruby9000 = <CODE>; jruby9000rc1 = <CODE>; zedtech = <CODE>; }`

## Nix Expressions: Environment #2

* Or we can do:
** `nix-instantiate --eval -E 'import <mychannel> { }'`
* Which auto assigns default arguments to evaluate same lazy result:
** `{ jruby1_7 = <CODE>; jruby1_7_20 = <CODE>; jruby1_7_20_1 = <CODE>; jruby9000 = <CODE>; jruby9000rc1 = <CODE>; zedtech = <CODE>; }`
* Or you could force strict evaluation (`--strict`), but it will print to stdout
  FOREVER! (Seriously not recommended or `pkill -9 nix-instantiate` will be
  necessary.)

## Nix Expressions: `nix-build`

* Build given Nix expression
  (or reads content of `default.nix` by default)

```bash
$ cat z/etc/pkg/myservice-server/default.nix
```

```nix
{ pkgs ? import <nixpkgs> {}
, serviceHost ? "localhost"
, servicePort ? 8080 }:
...
...
}
```

```bash
$ nix-build z/etc/pkg/myservice-server -A myservice-server
...
/nix/store/6xcbv034h8q3pfma0zjbsz3pnfr6x2bp-myservice-server
```

## Nix Expressions: `result/`

```bash
$ tree -L 3 -F result/
result
├── bin/
│   ├── myservice-server-deregister*
│   ├── myservice-server-post-start*
│   ├── myservice-server-post-stop*
│   ├── myservice-server-register*
│   ├── myservice-server-start*
│   └── myservice-server-status*
├── etc/
│   └── register.json
└── lib/
    └── myservice-all.jar

    3 directories, 8 files
```

## Nix Expressions: `nix-repl`

```bash
$ nix-repl

nix-repl> serviceName = "carson"
nix-repl> serviceName
"carson"

nix-repl> :t serviceName
a string

nix-repl> components = [ "bot" "brain" ]
nix-repl> components
[ "bot" "brain" ]

nix-repl> service = { name = serviceName; components = components; }
```

## Nix Expressions: Types

```
nix-repl> :t components
a list

nix-repl> :t { name = serviceName; components = components; }
a set

nix-repl> :t ~/.profile
a path

nix-repl> :t https://www.google.com
a string

nix-repl> :t 43
an integer

nix-repl> :t null
null

nix-repl> :t false
a boolean

nix-repl> builtins.toJSON { name = serviceName; components = components; deployed = true; }
"{\"components\":[\"bot\", \"brain\"],\"deployed\":true,\"name\":\"carson\"}"
```


## Nix Expressions: Builtins

```
nix-repl> builtins.typeOf []
"list"

nix-repl> builtins.typeOf {}
"set"

nix-repl> builtins.typeOf /home
"path"

nix-repl> builtins.head []
error: list index 0 is out of bounds, at (string):1:1

nix-repl> builtins.tail []
error: list index 0 is out of bounds, at (string):1:1

nix-repl> builtins.readDir /home
{ lost+found = "directory"; spotter = "directory"; }

nix-repl> buitlins.readDir /.
{ bin = "directory"; boot = "directory"; dev = "directory"; etc = "directory";...; var = "directory"; }

nix-repl> builtins.elemAt [ 1 2 3 4 5 ] 3
4

nix-repl> builtins.getEnv "USER"
"spotter"
```

## Nix Expressions: Importing

```
# File does not exist
nix-repl> fruits = import ./fruits.nix

# Not error raised yet but try to use the binding...and boom!
nix-repl> fruits
error: getting status of '/home/.../fruits.nix': No such file or directory

# When file exists
nix-repl> import ./z/doc/notes/services.nix
[ "userservice" "myservice" "adminservice" ]

nix-repl> import ./z/doc/notes/fun1.nix
<LAMBDA>
```

## Nix Expressions: Attrsets

```
nix-repl> builtins.removeAttrs { apple = "apfel"; banana = "banane"; cherry = "kirsche"; } [ "cherry" ]
{ apple = "apfel"; banana = "banane"; }

nix-repl> builtins.pathExists /home/tovelo
false

nix-repl> builtins.listToAttrs [ { name = "Elliphant"; value = "Ellinor Olovsdotter"; } { name = "MØ"; value = "Karen Marie Ørsted"; } { name = "Kerli"; value = "Kerli Kõiv"; } ]
{ Elliphant = "Ellinor Olovsdotter"; Kerli = "Kerli Kõiv"; MØ = "Karen Marie Ørsted"; }

nix-repl> builtins.length "yo yo yo"
error: value is a string while a list was expected, at (string):1:1

nix-repl> builtins.length [ 1 2 3 4 5 6 ]
6
```

## Nix Expressions: Concatenating

```
nix-repl> { sia = [ "Elastic Heart" ] ++ [ "Chandelier" ]; } // { tovelo = [ "Talking Body" ]; }
{ sia = [ "Elastic Heart" "Chandelier" ]; tovelo = [ "Talking Body" ]; }

nix-repl> { sia = [ "Chandelier" ]; } // { sia = [ "Elastic Heart" ]; }
{ sia = [ ... ]; }

# ZOMG lazy evaluation. Cheers!?
nix-repl> songs = { sia = [ "Chandelier" ]; } // { sia = [ "Elastic Heart" ]; }
nix-repl> songs.sia
[ "Elastic Heart" ]

# Ouch! Was it what you expected?
```

## Nix Expressions: Lambdas

```nix
{ nixpkgs ? import <nixpkgs> {}
, env ? builtins.getEnv "Z_DEPLOYMENT_ENV_TYPE"
, ... }:
let
  lib = nixpkgs.lib;
  domain = env: "${env}.lkt.is";

  zkServerIds = lib.range 0 2; #% yields [ 0 1 2 ] when evaluated (eventually)

  zkServerCfgF = env: idx: "server.${idx}=zookeeper${idx}.${domain env}:2888:3888";

  zkServerDevCfgF = zkServerCfgF "dev" #% lambda that takes one arg (idx)
  zkServerL = map zkServerDevCfgF (map toString zkServerIds);

  zkNodeDef = import ../node/zk.nix { inherit nixpkgs; }
in ...
```
