
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

$sysPackages = [ 'build-essential', 'curl', 'php5']
package { $sysPackages:
  ensure => "installed",
  require => Exec['apt-get update'],
  }


include git
include composer


# Apache, PHP, MYSQL and all other goodies

class { "apache":
mpm_module => 'prefork',
}


apache::mod { 'rewrite': }

include apache::mod::php

package { php-pear:
    ensure => installed,
  }

package { ['php-console-table','libapache2-mod-php5','php5-gd','php5-curl', 'python-software-properties', 'python', 'g++', 'make'] :
    ensure => installed,
    require => [Package['php-pear'], 
                  Exec['apt-get update']
                ]
  }

# Adding repo for Node JS
apt::ppa { 'ppa:chris-lea/node.js':
 require => Exec['apt-get update'],
 }



class { '::mysql::server':
  root_password    => 'root',
  override_options => $override_options
}
class { '::mysql::bindings':
  php_enable => 1,
  perl_enable => 1
}

# Use Augeas to modify php.ini and default apache config

augeas { "php.ini":
  notify  => Service[apache2],
  require => Package[php5],
  context => "/files/etc/php5/apache2/php.ini/PHP",
  changes => [
    "set post_max_size 10M",
    "set upload_max_filesize 50M",
    "set display_errors On",
    "set memory_limit -1",
    "set post_max_size 64M"
  ];
}
augeas { "override_config":
  require => Class['apache'],
  notify  => Service[apache2],
  changes => [
    "set /files/etc/apache2/sites-available/15-default.conf/VirtualHost/Directory/directive[2]/arg All",
  ],
}

# Create database

mysql::db { dev:
  user     => dev,
  password => dev,
  host     => 'localhost',
  grant    => ['ALL'],
}

# Install drush
exec { 'drush_install':
  command => '/usr/bin/pear channel-discover pear.drush.org && /usr/bin/pear install drush/drush',
  require => Package['php-console-table'],
  creates => '/usr/bin/drush'
}

# Install drupal and setup database
class finalInstall {
  exec { 'drupal_install':
    cwd => '/var/www',
    command => 'drush site-install -y --db-url=mysql://dev:dev@localhost:3306/dev --account-name=admin --account-pass=admin --site-name=dev',
    onlyif => '/usr/bin/test -f /var/www/sites/default/default.settings.php',
    creates => '/var/www/sites/default/settings.php',
    returns => '1',
  }
  exec { 'db_import' :
    cwd => '/var/www',
    command =>"drush sql-drop -y && drush sql-cli < /vagrant/'$latestdatabase' && drush vset cache 0 && drush vset block_cache 0 && drush vset preprocess_css 0 && drush vset preprocess_js 0 && drush cc all",
    onlyif =>'/usr/bin/test -f /var/www/sites/default/settings.php',
  }
  package { nodejs:
    ensure => installed,
  }
  exec {'grunt_cli':
    command => 'npm install -g grunt-cli',
    require => Package['nodejs'],
  }
}


class { "finalInstall":
  stage => last,
}
