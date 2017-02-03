# Class: rsync_cron
# ===========================
#
# rsync_cron - module which helps to create cron tasks on spoke servers or clients
# to sync files from hub server (server which stores source files)
#
# Created tasks use private SSH key to connect to server.
# You should install SSH private key with your own hands
#
# Paramaters
# ----------
# $package_name - package name which installs 'rsync' for current environment
# $package_ensure - rsync package state like in 'package' resource
#
# Examples
# --------
#
# # sync files from server every midnight.
# # Assumes, that another parameters are defaults
#    class { 'rsync_cron':
#      package_ensure => 'latest',
#    }
#    rsync_cron::get { 'get_files_from_server_example':
#      $source  = '/tmp/source_testfile',
#      $host    = 'myhost.mydomain',
#      $path    = '/tmp/destinatnion_testfile',
#      $user    = 'myuser',
#      $minute  = '0',
#      $hour    = '0',
#      $keyfile = '/root/.ssh/rsync_rsa',
#    }
# # Hiera:
#    rsync_cron::gets:
#      repo1:
#        server:      '192.168.122.1'
#        source:      '/tmp/source_testfile_repo2'
#        keyfile:     '/home/dev/.ssh/id_rsa'
#        user:        'dev'
#        destination: '/tmp/destination_testfile_repo2'
#        include:
#          - '/tmp/include_1'
#          - '/tmp/include_2'
#        exclude:
#          - '/tmp/exclude_1'
#          - '/tmp/exclude_2'
#        minute:       '0'
#        purge:        true
#        links:        true
#        hardlinks:    true           
#
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

class rsync_cron {
  #Install rsync with defaults
  include rsync
  
  $sync_jobs = lookup({
    name => 'rsync_cron::gets',
    value_type => Hash,
    default_value => {},
    })

  notify {"rsync_jobs list: ${sync_jobs} ":withpath => true}
  each($sync_jobs) |$name, $job| {
    rsync_cron::get { $name:
        * => $job
    }
    notify {"Job ID: ${job}": withpath => true}
  }
}
