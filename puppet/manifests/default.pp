
# Project name
$project = "penis"

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/bin/drush/", "$HOME/.composer/vendor/bin:$PATH"]}

# Run Stages
stage { 'pre':
  before => Stage["main"],
}

stage { 'last':
  require => Stage["main"],
}

# Essentials

exec { 'apt-get update':
  command => 'apt-get update',
  timeout => 60,
  tries   => 3
}

class { 'apt':
  always_apt_update => true,
}

$sysPackages = [ 'build-essential', 'curl']
package { $sysPackages:
  ensure => "installed",
  require => Exec['apt-get update'],
  }

include git
include composer


# Apache, PHP, MYSQL

class { "apache":
mpm_module => 'prefork',
}


apache::mod { 'rewrite': }

include apache::mod::php

package { php-pear:
    ensure => installed,
  }

package { 'php-console-table':
    ensure => installed,
    require => Package['php-pear']
  }

class { '::mysql::server':
  root_password    => 'root',
  override_options => $override_options
}

mysql::db { $project:
  user     => $project,
  password => $project,
  host     => 'localhost',
  grant    => ['ALL'],
}

exec { 'drush_install':
  command => '/usr/bin/pear channel-discover pear.drush.org && /usr/bin/pear install drush/drush',
  require => Package['php-console-table'],
  creates => '/usr/bin/drush'
}



