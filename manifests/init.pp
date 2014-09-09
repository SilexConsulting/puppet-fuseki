# == Class: fuseki
#
class fuseki (
  $fuseki_version = '1.0.2'
) {
  class {'fuseki::install': } ->
  class {'fuseki::config': } ~>
  class {'fuseki::service': } ->
  Class['fuseki']
}
