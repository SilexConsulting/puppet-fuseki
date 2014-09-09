# == Class: fuseki::config
# Download, install and configure fuseki
class fuseki::config {
  $file_name     = "jena-fuseki-${::fuseki::fuseki_version}-distribution.tar.gz"
  $download_site = 'http://archive.apache.org/dist/jena/binaries' # no trailing /

  # create fuseki user
  group { $::fuseki::params::fuseki_group:
    ensure => present,
  } ->
  user { $::fuseki::params::fuseki_user:
    ensure => present,
    gid    => $::fuseki::params::fuseki_group,
  }

  # Create the fuseki directory at $::fuseki::params::fuseki_home
  file { $::fuseki::params::fuseki_home:
    ensure    => directory,
    owner     => $::fuseki::params::fuseki_user,
    group     => $::fuseki::params::fuseki_group,
    mode      => '0755',
    require   => User[$::fuseki::params::fuseki_user],
  } ->
  # download and extract fuseki application to $::fuseki::params::fuseki_home
  exec { 'fuseki-download':
    command   => "wget ${download_site}/${file_name}",
    cwd       => '/tmp',
    creates   => "/tmp/${file_name}",
    onlyif    => "test ! -d ${::fuseki::params::fuseki_home}/WEB-INF && test ! -f /tmp/${file_name}",
    timeout   => 0,
  } ->
  exec { 'fuseki-extract':
    path      => ['/usr/bin', '/usr/sbin', '/bin'],
    command   => "tar xzvf ${file_name} --strip-components=1 -C ${::fuseki::params::fuseki_home}",
    cwd       => "/tmp",
    onlyif    => "test -f /tmp/${file_name} && test ! -f ${::fuseki::params::fuseki_home}/fuseki-server",
    user      => $::fuseki::params::fuseki_user,
  } ->
  # use a modified version of the startup script, which plays nicely with puppet
  file { '/etc/init.d/fuseki':
    ensure    => 'file',
    owner     => 'root',
    group     => 'root',
    source    => 'puppet:///modules/fuseki/fuseki',
  }

  file { $::fuseki::params::fuseki_settings:
    ensure    => 'file',
    owner     => 'root',
    group     => 'root',
    content   => template('fuseki/fuseki.erb'),
    require   => File['/etc/init.d/fuseki'], # after installation
  }

  # Create the fuseki logs directory at /var/log/fuseki
  file { "${::fuseki::params::fuseki_home}/logs":
    ensure    => directory,
    owner     => $::fuseki::params::fuseki_user,
    group     => $::fuseki::params::fuseki_group,
    mode      => '0755',
    require   => File['/etc/init.d/fuseki'], # after installation
  } ->
  file { $::fuseki::params::fuseki_logs:
    ensure    => 'link',
    target    => "${::fuseki::params::fuseki_home}/logs",
  }

  # Create the fuseki DB directory at $::fuseki::params::fuseki_home/DB
  file { "${::fuseki::params::fuseki_home}/DB":
    ensure    => directory,
    owner     => $::fuseki::params::fuseki_user,
    group     => $::fuseki::params::fuseki_group,
    mode      => '0755',
    require   => File['/etc/init.d/fuseki'], # after installation
  }
}
