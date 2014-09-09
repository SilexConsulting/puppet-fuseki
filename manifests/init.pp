# == Class: fuseki
#
class fuseki (
  $fuseki_version = $fuseki::params::fuseki_version
) inherits fuseki::params {
  class {'fuseki::install': } ->
  class {'fuseki::config': } ~>
  class {'fuseki::service': } ->
  Class['fuseki']
}
