# Class: jmxtrans
#
#
class jmxtrans inherits jmxtrans::params {
  case $::operatingsystem {
    'RedHat', 'CentOS': {
      $pkg_provider       = 'rpm'
      $package            = "jmxtrans-${jmxtrans::params::redhat_version}.noarch.rpm"
      $package_name       = inline_template("<%= @package[0..-5] %>")
      $tmpsource          = "/tmp/${package_name}"
      $defaults_file_path = '/etc/sysconfig/jmxtrans'
    }
    'Debian', 'Ubuntu': {
      $pkg_provider       = 'dpkg'
      $package            = "jmxtrans_${jmxtrans::params::debian_version}_all.deb"
      $package_name       = inline_template("<%= @package[0..-5] %>")
      $tmpsource          = "/tmp/${package_name}"
      $defaults_file_path = '/etc/default/jmxtrans'
    }
    default: {
      fail("${module_name} provides no package for ${::operatingsystem}")
    }
  }

  # Variables to build erb
  $java_home = $jmxtrans::params::java_home
  $seconds_between_run = $jmxtrans::params::seconds_between_run
  $json_dir = $jmxtrans::params::json_dir
  $heap_size = $jmxtrans::params::heap_size
  $new_size = $jmxtrans::params::heap_newgen_size
  $cpu_cores = $jmxtrans::params::cpu_cores
  $new_ratio = $jmxtrans::params::new_ratio

  file { $tmpsource:
    ensure  => present,
    source  => "puppet:///modules/${module_name}/${package}",
    backup  => false,
    owner   => 'root',
    group   => 'root',
    before  => Package[$package_name]
  }

  package { $package_name:
    ensure    => installed,
    source    => $tmpsource,
    provider  => $pkg_provider
  }

  file { "${defaults_file_path}":
    ensure => present,
    content => template("jmxtrans/jmxtrans.default.erb"),
    require => Package[$package_name]
  }

  service { "jmxtrans":
    enable      => true,
    ensure      => running,
    hasrestart  => true,
    hasstatus   => true,
    require     => [Package[$package_name], File[$defaults_file_path]]
  }
}