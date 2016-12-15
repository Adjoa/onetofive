class onetofive::websites {
  class { 'apache':
    default_vhost => false,
  }

  $vhosts = ['first', 'second', 'third', 'fourth', 'fifth']

  $vhosts.each |Integer $index, String $vhost| {
    $port = 80 + $index

    apache::vhost {"${vhost}.example.com":
      port    => $port,
      docroot => "/var/www/${vhost}",
    }

    file {"/var/www/${vhost}/default.html":
      ensure  => file,
      content => epp('profile/apache_default.html.epp', {'vhost' => $vhost}),
      require => Apache::Vhost["${vhost}.example.com"],
    }
  }
}
