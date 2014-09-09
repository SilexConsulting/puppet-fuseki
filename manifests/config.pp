# == Class: fuseki::config
# Download, install and configure fuseki
class fuseki::config {
  include fuseki::params

  $fuseki_version = $::fuseki::fuseki_version

  $fuseki_home     = $::fuseki::params::fuseki_home
  $fuseki_user     = $::fuseki::params::fuseki_user
  $fuseki_group    = $::fuseki::params::fuseki_group
  $fuseki_logs     = $::fuseki::params::fuseki_logs
  $fuseki_settings = $::fuseki::params::fuseki_settings

  $file_name                = "jena-fuseki-${fuseki_version}-distribution.tar.gz"
  $download_site            = 'http://archive.apache.org/dist/jena/binaries' # no trailing /

  # create fuseki user
  group { $fuseki_group:
    ensure => present,
  } ->
  user { $fuseki_user:
    ensure => present,
    gid    => $fuseki_group,
  }

  # Create the fuseki directory at $fuseki_home
  file { $fuseki_home:
    ensure    => directory,
    owner     => $fuseki_user,
    group     => $fuseki_group,
    mode      => '0755',
    require   => User[$fuseki_user],
  } ->
  # download and extract fuseki application to $fuseki_home
  exec { 'fuseki-download':
    command   => "wget ${download_site}/${file_name}",
    cwd       => '/tmp',
    creates   => "/tmp/${file_name}",
    onlyif    => "test ! -d ${fuseki_home}/WEB-INF && test ! -f /tmp/${file_name}",
    timeout   => 0,
  } ->
  exec { 'fuseki-extract':
    path      => ['/usr/bin', '/usr/sbin', '/bin'],
    command   => "tar xzvf ${file_name} --strip-components=1 -C ${fuseki_home}",
    cwd       => "/tmp",
    onlyif    => "test -f /tmp/${file_name} && test ! -d ${fuseki_home}/fuseki-server",
    user      => $fuseki_user,
  } ->
  # use a modified version of the startup script, which plays nicely with puppet
  file { '/etc/init.d/fuseki':
    ensure    => 'file',
    owner     => 'root',
    group     => 'root',
    source    => 'puppet:///modules/fuseki/fuseki',
  }

  file { '/etc/default/fuseki':
    ensure    => 'file',
    owner     => 'root',
    group     => 'root',
    content   => template('fuseki/fuseki.erb'),
    require   => File['/etc/init.d/fuseki'], # after installation
  }

  # Create the fuseki logs directory at /var/log/fuseki
  file { "${fuseki_home}/logs":
    ensure    => directory,
    owner     => $fuseki_user,
    group     => $fuseki_group,
    mode      => '0755',
    require   => File['/etc/init.d/fuseki'], # after installation
  } ->
  file { $fuseki_logs:
    ensure    => 'link',
    target    => "${fuseki_home}/logs",
  }

  # Create the fuseki DB directory at $fuseki_home/DB
  file { "${fuseki_home}/DB":
    ensure    => directory,
    owner     => $fuseki_user,
    group     => $fuseki_group,
    mode      => '0755',
    require   => File['/etc/init.d/fuseki'], # after installation
  }
}
