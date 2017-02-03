# Class: rsync_cron
# ===========================
#
# Full description of class rsync_cron here.
#
# Paramaters
# ----------
#---rsync variables
#   $server       - server to copy from
#   $source       - source path to copy from
#   $path         - path to copy to, defaults to $name
#   $user         - username on remote system
#   $purge        - if set, rsync will use '--delete'
#   $recursive    - if set, rsync will use '--recursive'
#   $links        - copy symlinks as symlinks, not files and folders.
#                   if set, rsync will use '--links'
#   $hardlinks    - if set, rsync will use '--hard-links'
#   $copylinks    - if set, rsync will use '--copy-links'
#   $times        - if set, rsync will use '--times'
#   $exlude       - string (or array) to be excluded
#   $include      - string (or array) to be included
#   $timeout      - timeout in seconds, defaults to 900
#   $options      - default options to pass to rsync (-a)
#   $chown        - USER:GROUP simple username/groupname mapping
#
#---SSH client variables
#   $keyfile      - path to ssh key used to connect to remote host
#   $known_hosts  - hash of ssh known hosts public keys.
#                   Key is hostname (or hostnames) string,
#                   value is key algorithm and key string
#   $known_hosts_file - path to known_hosts file,
#                       default is ~/.ssh/known_hosts
#                       for user which set with $execuser
#
#---Crontab variables
#   $minute       - crontab-like task start minute [0-59]
#   $hour         - crontab-like task start hour [0-23]
#   $day_of_month - crontab-like task start day of month [1-31]
#   $month        - crontab-like task start month [1-12]
#   $day_of_week  - crontab-like task start day of week [0-6]
#   $execuser     - user to run the command via cron
#
# Examples
# --------
#
# # sync files from server every midnight.
# # Assumes, that another parameters are defaults
#    class { 'rsync_cron':
#      $source  = '/tmp/source_testfile',
#      $host    = 'myhost.mydomain',
#      $path    = '/tmp/destinatnion_testfile',
#      $user    = 'myuser',
#      $minute  = '0',
#      $hour    = '0',
#      $keyfile = '/root/.ssh/rsync_rsa',
#    }
#
# Authors
# -------
#
# Ermakov Dmitriy <demonihin@gmail.com>
#
# Copyright
# ---------
#
# Copyright 2017 Dmitriy Ermakov
#
#

class rsync_cron (
  String                       $server,
  String                       $source,
  String                       $keyfile,
  String                       $user         = 'nobody',
  Hash                         $known_hosts  = {},
  Variant[String[1], Integer[0,59]]  $minute       = '*',
  Variant[String[1], Integer[0,59]]  $hour         = '*',
  Variant[String[1], Integer[0,31]]  $day_of_month = '*',
  Variant[String[1], Integer[1,12]]  $month        = '*',
  Variant[String[1], Integer[0,6]]   $day_of_week  = '*',
  String                       $path         = $name,
  Boolean                      $purge        = false,
  Boolean                      $recursive    = true,
  Boolean                      $links        = false,
  Boolean                      $hardlinks    = false,
  Boolean                      $copylinks    = false,
  Boolean                      $times        = true,
  Array[String]                $include      = [],
  Array[String]                $exclude      = [],
  Integer                      $timeout      = 900,
  String                       $execuser     = 'nobody',
  String                       $options      = '-a',
  String                       $chown        = $execuser,
) {
  #Contains useful functions.
  include stdlib
  #crontab support
  include cron::job

  #Add known hosts, without replace of already added by someone
  if $known_hosts {
    #create ~/.ssh/ directory if not exists
    file { "${::facts['home_dirs'][$execuser]}/.ssh/":
      ensure => 'directory',
    }
    #Add ssh public keys
    each($known_hosts)|$key, $value|{
      file_line { "ssh_known_host ${key}":
        line => "${key} ${value}",
        path => "${::facts['home_dirs'][$execuser]}/.ssh/known_hosts",
      }
    }
  }

  $rsync_params = ['rsync',] #crontab rsync command line
  if $purge {
    $rsync_params = $rsync_params + '--purge'
  }

  if $recursive {
    $rsync_params = $rsync_params + '--recursive'
  }

  if $links {
    $rsync_params = $rsync_params + '--links'
  }
  
  if $hardlinks {
    $rsync_params = $rsync_params + '--hardlinks'
  }
  
  if $copylinks {
    $rsync_params = $rsync_params + '--copylinks'
  }
  
  if $times {
    $rsync_params = $rsync_params + '--times'
  }

  if $timeout {
    $rsync_params = $rsync_params + "--timeout=${timeout}"
  }

  if $options {
    $rsync_params = $rsync_params + $options
  }

  if $chown {
    $rsync_params = $rsync_params + "--chown=${chown}"
  }

  if $exclude {
    each($exclude) |$item| {
      $rsync_params = $rsync_params + "--exclude=${item}"
    }
  }

  if $include {
    each($include) |$item| {
      $rsync_params = $rsync_params + "--include=${item}"
    }
  }

  if $server and $source and $path and $user and $keyfile {
    $rsync_params = $rsync_params + "-e 'ssh -i ${keyfile} -l ${user}'"
    $rsync_params = $rsync_params + "${user}@${server}:${source} ${path}"
  }
  
  $rsync_command = join($rsync_params, ' ')
  
  #Set cron jobs
  cron::job { "rsync from server ${server}:${path}":
    $::cron::job::command     => $rsync_command,
    $::cron::job::ensure      => 'present',
    $::cron::job::minute      => $minute,
    $::cron::job::hour        => $hour,
    $::cron::job::date        => $day_of_month,
    $::cron::job::month       => $month,
    $::cron::job::weekday     => $day_of_week,
    $::cron::job::user        => $execuser,
    $::cron::job::description => "rsync from server ${server}:${path} to ${path}",
  }
}
