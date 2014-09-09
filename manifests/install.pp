# == Class fuseki::install
# Pre-conditions that must be met before Fuseki can be installed

class fuseki::install {
  include fuseki::params

  package { 'default-jdk':
    ensure  => present,
  }

  package { 'wget':
    ensure  => present,
  }
}
