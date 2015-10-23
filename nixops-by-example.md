---
layout: page
title: NixOps By Example
---

## Terminology Mapping

Mapping from Terraform terms to NixOps:

* State => `NIXOPS_STATE` (sqlite3 database)
* Provider (higher "coverage") => Targets
* Module => Nix expression (which is more expressive
* Plugins => called backens in NixOps (roughly speaking)

Comparison notes:

* Implemented in Go and custom DSL => Nix expressions driven by Python using older boto :(
* Terraform has much greater ec2/AWS coverage than NixOps!
* Terraform does not have a _provisioner_ for NixOS configuration
* Terraform's DSL is not as flexible as Nix expression language

## NixOps: Basic Workflow

```bash
$ nixops create -d my-unique-deployment-name -s /var/data/nixops/devdeploys.nixops
...
$ nixops deploy -d my-unique-deployment-name -s /var/data/nixops/devdeploys.nixops
...
# make changes to deployment definition now then deploy incremental changes
$ nixops deploy -d my-unique-deployment-name -s /var/data/nixops/devdeploys.nixops
...
# destroy running resources in the deployment my-unique-deployment-name
$ nixops destroy -d my-unique-deployment-name -s /var/data/nixops/devdeploys.nixops
...
# delete deployment definition completely from the database
$ nixops delete -d my-unique-deployment-name -s /var/data/nixops/devdeploys.nixops
...
```

## NixOps: Common Commands

```bash
$ echo $NIXOPS_STATE # points to sqlite3 deployments database to avoid `-s` arg
...
$ nixops list # lists all deployments in $NIXOPS_STATE
...
$ nixops create -d easy-name z/etc/service/default.nix
...
$ nixops deploy -d easy-name
...
$ nixops info -d easy-name # shows state of deployment
...
$ nixops check -d easy-name # runs basic checks on deployment
...
$ nixops ssh -d easy-name machineName # SSHes into specified machine
...
$ nixops ssh-for-each -d easy-name # Loops SSH through
...
$ nixops list-generations -d easy-name
...
$ nixops show-option -d easy-name machineName services.ntp.servers # shows value of thi
...
```

## NixOps: Other Commands

```bash
$ nixops backup -d easy-name
...
$ nixops restore -d easy-name
...
$ nixops dump-nix-paths -d dataplatform-dev-spotter-virtualbox-cluster
/nix/store/fj0cxkwb6sday2970jsdmj9vlqgkj5jm-nixops-machines

$ nix-store -qR /nix/store/fj0cxkwb6sday2970jsdmj9vlqgkj5jm-nixops-machines
/nix/store/5hkwn27l77b7c37z7812acdf4p9ldr6m-linux-headers-3.12.32
/nix/store/i0l0jjkk82wsqz9z5yhg35iy78bjq684-glibc-2.21
/nix/store/027119xc9wx84pblxbh8hr8mq7l603fp-libgpg-error-1.19
/nix/store/7smzp7br1slr9081ams5yrma26azjgww-libffi-3.2.1
/nix/store/8nlcagwvlk246jyjj423yqwv2yzrclq1-expat-2.1.0
/nix/store/60nvlmj63b87xxfw20sg7ww3g84ijcq5-zlib-1.2.8
/nix/store/cpv8pyc772cx0spzz76sa6dvsf6555dh-gcc-4.8.4
...
/nix/store/xqhzq4z180z62qqyrl7cqmp1gbxi89bq-unit-zookeeper.service
/nix/store/sn3dcp3asf1cf78y7c4l5gvjskfwvxck-system-units
/nix/store/w1x1nvzf2ys012w4idw6w59f86qywq34-etc
/nix/store/rs3phqmrv91ipbhjl2a1427f5hzgcrsq-nixos-15.06.git.4277d71M
/nix/store/fj0cxkwb6sday2970jsdmj9vlqgkj5jm-nixops-machines
```

## NixOps: Basic Deployment Definition

```nix
{ region ? "us-west-2" # defaults to us-west-2
, ec2defaults ? import <mychannel/utils/ec2/defaults> {}
let

  backend =
    { config, pkgs, region, zone, keyId, ec2defaults, ... }:
    {
      services.something.enable = true;
      # Other stuff here...
      deployment.targetEnv = "ec2";
      deployment.ec2.accessKeyId = keyId;
      deployment.ec2.ami = ec2defaults.amiForRegion region;
      deployment.ec2.tags.Service = "myservice";
      deployment.ec2.tags.Component = "server";
      deployment.ec2.tags.Custom = "woot";
    };

in

{
  network.description = "Service backends";

  backend0 = backend { inherit ec2defaults region; zone = "${region}a"; };
  backend1 = backend { inherit ec2defaults region; zone = "${region}b"; };
  backend2 = backend { inherit ec2defaults region; zone = "${region}c"; };
}
```
