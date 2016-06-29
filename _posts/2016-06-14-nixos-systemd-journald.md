---
layout: post
title: Tips &amp; tricks for systemd and journald on NixOS
---

This document contains a list of tips and tricks for working with systemd,
journalctl, and related tools.

### SysVinit vs Upstart vs Systemd

The simplest cheatsheet:

<table>
<tr>
  <td>SysVinit</td>
  <td>Upstart</td>
  <td>Systemd</td>
</tr>
<tr>
  <td>/etc/init.d/service start</td>
  <td>start service</td>
  <td>systemctl start service</td>
</tr>
<tr>
  <td>/etc/init.d/service stop</td>
  <td>stop service</td>
  <td>systemctl stop service</td>
</tr>
<tr>
  <td>/etc/init.d/service restart</td>
  <td>restart service</td>
  <td>systemctl restart service</td>
</tr>
<tr>
  <td>/etc/init.d/service status</td>
  <td>status service</td>
  <td>systemctl status service</td>
</tr>
</table>

### Systemd Unit Types

Systemd has the following unit types you might be concerned with:

* *services:* A service unit describes how to manage a typically long-running
  application process. This includes how to start, stop, reload, etc the
  service, under which circumstances it should be automatically started,
  timeout periods or events, and the dependency or ordering relative to other
  systemd units.
  In NixOS you can create a new systemd service like so:

  ```nix
  systemd.services.myservice = {
    description = "My service is responsible for ...";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.bash ];
    environment = {
      MY_SERVICE_HOME = "/my/path/here";
      MY_SERVICE_MAX_CONNS = toString myVar;
    };
    serviceConfig = {
      User = "myuser";
      ExecStart = path;
      Restart = "always";
    };
  };
  ```

* *paths:* This type of unit defines a path to be used for path-based
  activation. For example, service units could be started, restarted, stopped,
  reloaded, etc when the file a path unit represents encounters a specific
  state. `inotify` is used to monitor the path for state changes.
* *slices:*  Slice units map to Linux Control Groups. This allows resources
  to be restricted or assigned to processes associated with the slice. The
  root slice is named `-.slice`.
* *sockets:* A socket unit describes a network or IPC socket, or a FIFO
  buffer that systemd uses for socket-based activation. Socket units are
  associated to services to trigger their start.
* *swaps:* This unit describes swap space on the system.
* *targets:* A target unit is used to provide synchronization points for other
  units when booting up or changing states. The target of interest to most
  systemd service definers will likely be `multi-user.target`.
* *timers:* Timer units define a timer managed by systemd. It represents a
  periodic or event-based activation. A matching unit, typically a service,
  will be started when the timer or event requirements are met.

Systemd has other types of units but the above list is a good starting point.
For more information please consult `man systemctl`.

The following commands can be used to query information about systemd
units:

```bash
# List dependencies for a unit
$ systemctl list-dependencies UNITNAME

# List sockets
$ systemctl list-sockets

# List active systemd jobs
$ systemctl list-jobs

# List all units and their respective states
$ systemctl list-unit-files

# List all loaded or active units
$ systemctl list-units

```

### Systemd Services

Most of the time we will be concerned with systemd services.
Below are a list of useful commands for working with these:

```bash
# Need to have sudo privileges to stop/start/restart services
$ sudo systemctl stop SERVICE
$ sudo systemctl start SERVICE
$ sudo systemctl restart SERVICE

# Query commands anyone can run
$ systemctl status SERVICE
$ systemctl is-active SERVICE
$ systemctl show SERVICE
```

You can also run `systemctl` commands remotely like so:

```
$ systemctl -H hostname status SERVICE
```

This works for `systemctl` commands other than just
systemd service specific commands.

### Log Accessibility By `journalctl`

For all services that need logs accessed via `journalctl` you should log to
the console from a systemd unit.

For example, Elasticsearch logging configuration can be set as so:

```
rootLogger: INFO, console
logger:
  action: INFO
  com.amazonaws: WARN
appender:
  console:
    type: console
    layout:
      type: consolePattern
      conversionPattern: "[%d{ISO8601}][%-5p][%-25c] %m%n"
```

Then you will be able to query logs from the `elasticsearch` service unit by
using:

```
$ journalctl -f -u elasticsearch
```

### Accessing Logs Via `journalctl`

```
# tail "follow" all log messages for elasticsearch unit/service
$ journalctl -f -u elasticsearch

# show last 1000 error messages for elasticsearch unit/service (command
# terminates without ^C)
$ journalctl -fen1000 -u elasticsearch

# only show kernel messages in tail "follow" mode:
$ journalctl -k -f

# only show log messages for service BLA since last "boot"
$ journalctl -b -u BLA

# show all error log messages from all log sources since last "boot"
$ journalctl -xab
```

Many more permutations of options are available on `journalctl`. Please
consult `man journalctl` for more information.

### User Access To `journalctl` Logs

All users that are in the `systemd-journal` group should be able to query logs
via `journalctl`. Ensure your SSH user is in this group via `groups USERNAME`.

### NixOS Configuration for `journald`

The NixOS expression for a node's configuration contains the following settings
that are worth tuning on servers with high frequency events being logged.

As of NixOS 16.03, the defaults for `services.journald.rateLimitBurst` and
`services.journald.rateLimitInterval` are worth evaluating for your needs:

```bash
$ sudo nixos-option services.journald.rateLimitBurst
Value:
100

Default:
100

Description:

Configures the rate limiting burst limit (number of messages per
interval) that is applied to all messages generated on the system.
This rate limiting is applied per-service, so that two services
which log do not interfere with each other's limit.

...
```

And:

```bash

$ sudo nixos-option services.journald.rateLimitInterval
Value:
"10s"

Default:
"10s"

Description:

Configures the rate limiting interval that is applied to all
messages generated on the system. This rate limiting is applied
per-service, so that two services which log do not interfere with
each other's limit. The value may be specified in the following
units: s, min, h, ms, us. To turn off any kind of rate limiting,
set either value to 0.

```

This means on this system `journald` will rate limit events per
service after 100 messages within 10s. For many servers this is
low, and you will want to adjust it with values like the following:

```nix
  services.journald.rateLimitBurst = 1000;
  services.journald.rateLimitInterval = 1s;
```

The above will rate limit services to logging 1000 messages per second.

You can also turn off rate limiting in `journald` with the following:

```nix
  services.journald.rateLimitInterval = 0;
```
