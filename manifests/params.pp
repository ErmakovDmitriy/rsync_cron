#Module params
#
class rsync_cron::params {
  
  $ssh_client_package_name = $facts['os']['family'] ? {
    /(?i:redhat|centos|fedora)/ => 'openssh-clients',
    /(?i:debian|ubuntu)/ => 'openssh-client',
    default  => 'ssh',
  }

}
