# == Class fuseki::service
#
# Ensure that the fuseki service is running
class fuseki::service {
  include fuseki::params

  $service_name   = $::fuseki::params::service_name

  service { $service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => false,
  }
}
