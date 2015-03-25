# == Class: fuseki
#
class fuseki (
  $fuseki_version = $fuseki::params::fuseki_version
  $fuseki_data_dir  = $fuseki::params::fuseki_data_dir,
) inherits fuseki::params {
  class {'fuseki::install': } ->
  class {'fuseki::config':
    fuseki_data_dir  => $fuseki_data_dir,
  } ~>
  class {'fuseki::service': } ->
  Class['fuseki']
}
