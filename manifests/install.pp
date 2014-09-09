# == Class fuseki::install
# Pre-conditions that must be met before Fuseki can be installed

class fuseki::install {
  include beluga::wget
  include beluga::java
}
