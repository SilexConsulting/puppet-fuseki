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
      $home                               = '/usr/share/fuseki'
      $logs                               = '/var/log/fuseki'
      $version                            = '1.0.2'
      $user                               = 'fuseki'
      $group                              = 'fuseki'

      $service_name                       = 'fuseki'

      $config                             = 'puppet:///modules/fuseki/'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
