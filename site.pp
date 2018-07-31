node default {
    # Test message
    notify { "Debug output on ${hostname} node.": }
    class { 'apache': }             # use apache module
    apache::vhost { 'example.com':  # define vhost resource
        port    => '80',
        docroot => '/var/www/html'
    }
}

node 'node01.example.com', 'node02.example.com' {
    # Test message
    notify { "Debug output on ${hostname} node.": }

    class { 'apache': }             # use apache module
    apache::vhost { 'example.com':  # define vhost resource
        port    => '80',
        docroot => '/var/www/html'
    }
}
