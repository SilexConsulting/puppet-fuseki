# == Class: fuseki
#
class fuseki inherits fuseki::params {

  class {'fuseki::install': } ->
  class {'fuseki::config': } ~>
  class {'fuseki::service': } ->
  Class['fuseki']
}
