# == Class fuseki::params

class fuseki::params {
  $fuseki_version   = '1.0.2'
  $fuseki_user      = 'fuseki'
  $fuseki_group     = 'fuseki'
  $fuseki_settings  = '/etc/default/fuseki'

  $fuseki_home      = '/usr/share/fuseki'
  $fuseki_logs      = "${fuseki_home}/logs"
  $fuseki_lib       = '/var/lib/fuseki'
  $fuseki_backups   = "${fuseki_lib}/backups"
  $fuseki_databases = "${fuseki_lib}/databases"

  $service_name     = 'fuseki'
  $config           = 'puppet:///modules/fuseki/'
  $fuseki_args      = ''
  $fuseki_java_options = ''

  case $::osfamily {
    'Debian': {
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
