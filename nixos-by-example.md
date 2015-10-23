---
layout: page
title: NixOS By Example
---

## Terminology Mapping

Chef to Nix:

Chef | Nix/NixOS
* `run_list` (Ruby DSL) => Nix expression
* `cookbook` (Ruby metadata DSL et al) => Nix expression (attrset)
* `recipe` (Ruby DSL) => Nix expression (module)
* `attributes` (JSON/Ruby/...) => Nix expression (attrset)
* `data_bag` (JSON/Ruby/...) => Nix expression (attrset)
* `environments` (JSON/Ruby/...) => Nix expression (attrset)
* `libraries` (Ruby) => Nix expression (functions and data)
* `resources` (Ruby) => Nix expression (functions and data)
* `files` => File
* `templates` (ERB) => Files using vars and expressions

## NixOS: Setup

```nix
{ config, pkgs, ... }:
let ntpF = (idx: "${idx}.amazon.pool.ntp.org") in
{
  time.timeZone = "UTC";

  networking.hostName = "dubstep.dev.lkt.is";
  networking.nameservers = [ "208,67.222.222" "8.8.8.8" ];
  networking.firewall.enable = true;

  nixpkgs.config.allowUnfree = true;

  services.ntp.enable = true;
  services.ntp.servers = map ntpF (nixpkgs.lib.range 0 3)

  users.extraUsers.ellinor = {
    isNormalUser = true;
    group = "artists";
    description = "Elliphant";
    createHome = true;
    home= "/home/ellinor";
  };

  security.pki.certificateFiles = [ ./mydomain_ca.crt ];
  boot.kernel.sysctl."net.ipv4.tcp_keepalive_time" = 1500;
}
```

link:http://nixos.org/nixos/manual/sec-configuration-syntax.html[Reference Documentation]


## NixOS: Using Modules

```nix
  # inside your NixOS configuration
  services.mysql.enable = true;
  services.mysql.package = mychannel.percona_5_6;
  services.mysql.dataDir = "/data";
  services.mysql.port = 3306; # default value anyway
  services.mysql.initialScript = ''
    GRANT ALL ON ${databaseName}.*
      TO ${databaseUser}@localhost
      IDENTIFIED BY "${databasePassword}";
  '';
```

## NixOS: Option Usage

```bash
$ nixos-option services.mysql.replication.role
Value:
"none"

Default:
"none"

Description:

Role of the MySQL server instance. Can be either: master, slave or none
Declared by:
  "/home/spotter/src/nixos/nixpkgs/nixos/modules/services/databases/mysql.nix"

Defined by:
  "/home/spotter/src/nixos/nixpkgs/nixos/modules/services/databases/mysql.nix"
```

## NixOS: Writing Modules

```nix
{ config, lib, pkgs, ... }:
let paths = [ ./bla.nix ./other.nix ]; in
with lib; {
  imports = paths;

  options = {
    habitsremixloop.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable habitsremixloop service";
    };
    habitsremixloop.styles = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "debstep" "trance" "house" ];
      description = "The types of remix styles to include.";
    };
  };

  config = mkIf config.services.habitsremixloop.enable {
    environment.systemPackages = [ habitsremixloop ];
    systemd.services.habitsremixloop = ...;
  };
}
```

## NixOS: Options & Docs

```bash
$ nixos-option security.pki
This attribute set contains:
certificateFiles
certificates

$ nixos-option security.pki.certificateFiles
...
```

Or visit the link:http://nixos.org/nixos/options.html[NixOS options search page].

