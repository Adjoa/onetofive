class onetofive::databases {
  include apt

  apt::source { 'mariadb':
    location => 'http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.1/ubuntu',
    release  => $::lsbdistcodename,
    repos    => 'main',
    key      => { 
      id     => '199369E5404BD5FC7D2FE43BCBCB082A1BB943DB',
      server => 'hkp://keyserver.ubuntu.com:80',
    },
    include => {
      src   => false,
      deb   => true,
    },
  }

  class {'::mysql::server':
    package_name     => 'mariadb-server',
    package_ensure   => '10.1.19+maria-1~trusty',
    service_name     => 'mysql',
    root_password    => hiera('profile::mysql::server_password'),
    override_options => {
      mysqld => {
        'log-error' => '/var/log/mysql/mariadb.log',
	'pid-file'  => '/var/run/mysqld/mysqld.pid',
      },
      mysqld_safe => {
	'log-error' => '/var/log/mysql/mariadb.log',
      },
    }
  }

  class {'::mysql::client':
    package_name    => 'mariadb-client',
    package_ensure  => '10.1.19+maria-1~trusty',
    bindings_enable => true,
  }

  Apt::Source['mariadb'] ~>
  Class['apt::update'] ->
  Class['::mysql::server'] ->
  Class['::mysql::client']

  $dbs = ['first', 'second', 'third', 'fourth', 'fifth']

  $dbs.each |String $db| {
    mysql::db {"${db}-db":
      user     => 'myuser',
      password => hiera('profile::mysql::db_password'),
    }
  }
}
