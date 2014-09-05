# == Class: fuseki::config
# Download, install and configure fuseki
class fuseki::config {
  include fuseki::params

  $version                  = $::fuseki::params::version

  $home                     = $::fuseki::params::home
  $logs                     = $::fuseki::params::logs

  $user                     = $::fuseki::params::user
  $group                    = $::fuseki::params::group

  $file_name                = "jena-fuseki-${version}-distribution.tar.gz"
  $download_site            = 'http://archive.apache.org/dist/jena/binaries' # no trailing /

  # create fuseki user
  group { $group:
    ensure => present,
  } ->
  user { $user:
    ensure => present,
    gid    => $group,
  }

  # Create the fuseki directory at $home
  file { $home:
    ensure    => directory,
    owner     => $user,
    group     => $group,
    mode      => '0755',
    require   => User[$user],
  } ->
  # download and extract fuseki application to $home
  exec { 'fuseki-download':
    command   => "wget ${download_site}/${file_name}",
    cwd       => '/tmp',
    creates   => "/tmp/${file_name}",
    onlyif    => "test ! -d ${home}/WEB-INF && test ! -f /tmp/${file_name}",
    timeout   => 0,
  } ->
  exec { 'fuseki-extract':
    path      => ['/usr/bin', '/usr/sbin', '/bin'],
    command   => "tar xzvf ${file_name} --strip-components=1 -C ${home}",
    cwd       => "/tmp",
    onlyif    => "test -f /tmp/${file_name} && test ! -d ${home}/fuseki-server",
    user      => $user,
  } ->
  # use a modified version of the startup script, which plays nicely with puppet
  file { '/etc/init.d/fuseki':
    ensure    => 'file',
    owner     => 'root',
    group     => 'root',
    source    => 'puppet:///modules/fuseki/fuseki',
  } ->
  file { '/etc/default/fuseki':
    ensure    => 'file',
    owner     => 'root',
    group     => 'root',
    content   => template('fuseki/fuseki.erb'),
  }

  # Create the fuseki logs directory at /var/log/fuseki
  file { "${home}/logs":
    ensure    => directory,
    owner     => $user,
    group     => $group,
    mode      => '0755',
    require   => File["${home}/fuseki"], # after installation
  } ->
  file { '/var/log/fuseki':
    ensure    => 'link',
    target    => "${home}/logs",
  }

  # Create the fuseki DB directory at $home/DB
  file { "${home}/DB":
    ensure    => directory,
    owner     => $user,
    group     => $group,
    mode      => '0755',
    require   => File["${home}/fuseki"], # after installation
  }
}
