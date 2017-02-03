# resource: rsync_cron::get
# ===========================
#
# Represents one cron rsync job. You can use this to sync files from server.
#
# Paramaters
# ----------
#---rsync variables
#   $server       - server to copy from
#   $source       - source path to copy from
#   $destination  - path to copy to, defaults to $name
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
#   $known_hosts  - Hash of ssh known hosts public keys.
#                   Key is any unique string.
#                   Value is key algorithm and key string
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
#    rsync_cron::get { 'get_files_from_server_example':
#      $source  = '/tmp/source_testfile',
#      $host    = 'myhost.mydomain',
#      $destination    = '/tmp/destinatnion_testfile',
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

define rsync_cron::get (
  String                             $server,
  String                             $source,
  String                             $keyfile,
  String                             $user         = 'nobody',
  Hash                               $known_hosts  = {},
  Variant[String[1], Integer[0,59]]  $minute       = '*',
  Variant[String[1], Integer[0,59]]  $hour         = '*',
  Variant[String[1], Integer[0,31]]  $day_of_month = '*',
  Variant[String[1], Integer[1,12]]  $month        = '*',
  Variant[String[1], Integer[0,6]]   $day_of_week  = '*',
  String                             $destination  = $name,
  Boolean                            $purge        = false,
  Boolean                            $recursive    = true,
  Boolean                            $links        = false,
  Boolean                            $hardlinks    = false,
  Boolean                            $copylinks    = false,
  Boolean                            $times        = true,
  Array[String]                      $include      = [],
  Array[String]                      $exclude      = [],
  Integer                            $timeout      = 900,
  String                             $execuser     = 'nobody',
  String                             $options      = '-a',
  String                             $chown        = 'nobody',
  Enum['present','absent']           $ensure       = 'present',
) {
  #Contains useful functions.
  include stdlib
  #crontab support
  include cron

  #Add known hosts, without replace of already added by someone
  unless empty($known_hosts) {
    #create ~/.ssh/ directory if not exists.
    #Ensure_resource used to resolve 'duplicate resource' error.
    ensure_resource('file',"${::facts['home_dirs'][$execuser]}/.ssh/",{
      ensure => 'directory',
      owner  => $execuser,
      mode   => '0700',
      })
    ensure_resource('file',"${::facts['home_dirs'][$execuser]}/.ssh/known_hosts",{
      ensure => 'file',
      owner  => $execuser,
      mode   => '0700',
      })

    #Add ssh public keys
    each($known_hosts)|$key, $value|{
      file_line { "ssh_known_host ${key}":
        ensure => $ensure,
        line   => $value,
        path   => "${::facts['home_dirs'][$execuser]}/.ssh/known_hosts",
      }
    }
  }

  $rsync_params = ['rsync',] #crontab rsync command line
  if $purge {
    $option_purge = '--purge'
  }

  if $recursive {
    $option_recursive = '--recursive'
  }

  if $links {
    $option_links = '--links'
  }
  
  if $hardlinks {
    $option_hardlinks = '--hardlinks'
  }
  
  if $copylinks {
    $option_copylinks = '--copylinks'
  }
  
  if $times {
    $option_times = '--times'
  }

  if $timeout {
    $option_timeout = "--timeout=${timeout}"
  }

  if $chown {
    $option_chown = "--chown=${chown}"
  }

  if $exclude {
    $option_exclude = join($exclude, ' --exclude=')
  }

  if $include {
    $option_include = join($include, ' --include=')
  }

  if $server and $source and $destination and $user and $keyfile {
    $ssh_command = "-e 'ssh -i ${keyfile} -l ${user}'"
    $copy_paths = "${user}@${server}:${source} ${destination}"
  }

  $configured_params = delete_undef_values([$option_purge, $option_recursive,
                                            $option_links, $option_hardlinks,
                                            $option_copylinks,
                                            $option_times, $option_timeout,
                                            $option_chown, $option_exclude,
                                            $option_include, $ssh_command,
                                            $copy_paths,])
  #notify { "Params: ${configured_params}" : withpath => true }
  $rsync_command = join($configured_params, ' ')

  #notify {"Rsync command: ${rsync_command}": withpath => true}
  # #Set cron jobs
  cron::job { "rsync_${name}":
    ensure      => $ensure,
    command     => $rsync_command,
    minute      => $minute,
    hour        => $hour,
    date        => $day_of_month,
    month       => $month,
    weekday     => $day_of_week,
    user        => $execuser,
    description => "rsync from server ${server}:${path} to ${path} name: ${name}",
  }
}
