# == Class: fuseki::config
# Download, install and configure fuseki
class fuseki::config {
  $file_name     = "jena-fuseki-${::fuseki::fuseki_version}-distribution.tar.gz"
  $download_site = 'http://archive.apache.org/dist/jena/binaries' # no trailing /

  # create fuseki user and group

  group { $fuseki::params::fuseki_group:
    ensure => present,
  }

  user { $fuseki::params::fuseki_user:
    ensure    => present,
    gid       => $fuseki::params::fuseki_group,
    require   => Group[$fuseki::params::fuseki_group]
  }

  # Create directories and symlinks fuseki requires

  file { [$fuseki::params::fuseki_home,
          $fuseki::params::fuseki_lib,
          $fuseki::params::fuseki_backups,
          $fuseki::params::fuseki_databases,
          $fuseki::params::fuseki_logs]:
    ensure    => directory,
    owner     => $fuseki::params::fuseki_user,
    group     => $fuseki::params::fuseki_group,
    mode      => '0755',
    require   => User[$fuseki::params::fuseki_user],
  }

  file { '/var/log/fuseki':
    ensure    => 'link',
    target    => $fuseki::params::fuseki_logs,
    require   => File[$fuseki::params::fuseki_logs],
  }

  file { "${fuseki::params::fuseki_home}/backups":
    ensure    => 'link',
    target    => $fuseki::params::fuseki_backups,
    require   => File[$fuseki::params::fuseki_backups]
  }

  # Download and extract the fuseki application to $fuseki::params::fuseki_home

  exec { 'fuseki-download':
    command   => "wget ${download_site}/${file_name}",
    cwd       => '/tmp',
    creates   => "/tmp/${file_name}",
    onlyif    => "test ! -f ${fuseki::params::fuseki_home}/fuseki-server && test ! -f /tmp/${file_name}",
    timeout   => 0,
    require   => File[$fuseki::params::fuseki_home],
  }

  exec { 'fuseki-extract':
    path      => ['/usr/bin', '/usr/sbin', '/bin'],
    command   => "tar xzvf ${file_name} --strip-components=1 -C ${fuseki::params::fuseki_home}",
    cwd       => "/tmp",
    onlyif    => "test -f /tmp/${file_name} && test ! -f ${fuseki::params::fuseki_home}/fuseki-server",
    user      => $fuseki::params::fuseki_user,
    require   => Exec['fuseki-download'],
  }

  # Use a modified version of the startup script, which plays nicely with puppet

  file { '/etc/init.d/fuseki':
    ensure    => 'file',
    owner     => 'root',
    group     => 'root',
    source    => 'puppet:///modules/fuseki/fuseki',
  }

  # Add FUSEKI_HOME environemnt variable

  file { $fuseki::params::fuseki_settings:
    ensure    => 'file',
    owner     => 'root',
    group     => 'root',
    content   => template('fuseki/fuseki.erb'),
  }
}
