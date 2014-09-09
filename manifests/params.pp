# == Class fuseki::params
#
# === Parameters
#
# [*source_dir*]
#   If defined, the whole fuseki configuration directory content is retrieved recursively from
#   the specified source (parameter: source => $source_dir , recurse => true)
#
# [*source_dir_purge*]
#   If set to true all the existing configuration directory is overriden by the
#   content retrived from source_dir. (source => $source_dir , recurse => true , purge => true)
#
class fuseki::params {
  case $::osfamily {
    'Debian': {
      $fuseki_home     = '/usr/share/fuseki'
      $fuseki_user     = 'fuseki'
      $fuseki_group    = 'fuseki'
      $fuseki_logs     = '/var/log/fuseki'
      $fuseki_settings = '/etc/default/fuseki'
      $service_name    = 'fuseki'
      $config          = 'puppet:///modules/fuseki/'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
