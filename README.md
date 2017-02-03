# rsync_cron

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with rsync_cron](#setup)
    * [What rsync_cron affects](#what-rsync_cron-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with rsync_cron](#beginning-with-rsync_cron)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module manages rsync file copy tasks, which initiated with cron daemon.
You can create copy task and this task will start on time.

This module are for simplier using rsync schedule.

Module 'themeier-rsync' was the prototype for this module,
but themeier-rsync starts with puppet agent apply action,
not by more precise cron schedule.
Also 'rsync_cron' manages ssh known_hosts file.


## Setup

This module installs: ssh client, cron daemon, rsync packages.

Dependencies: puppetlabs-stdlib, rmueller-cron, ghoneycutt-ssh, themeier-rsync.


### Beginning with rsync_cron

The very basic steps needed for a user to get the module up and running. This
can include setup steps, if necessary, or it can be an example of the most
basic use of the module.

## Usage

This section is where you describe how to customize, configure, and do the
fancy stuff with your module here. It's especially helpful if you include usage
examples and code samples for doing things with your module.

## Reference

Here, include a complete list of your module's classes, types, providers,
facts, along with the parameters for each. Users refer to this section (thus
the name "Reference") to find specific details; most users don't read it per
se.

## Limitations

This is where you list OS compatibility, version compatibility, etc. If there
are Known Issues, you might want to include them under their own heading here.

## Development

Since your module is awesome, other users will want to play with it. Let them
know what the ground rules for contributing are.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You can also add any additional sections you feel
are necessary or important to include here. Please use the `## ` header.
