# == Class fuseki::service
#
# Ensure that the fuseki service is running
class fuseki::service {
  service { $::fuseki::params::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
