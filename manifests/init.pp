# Class: jmxtrans
#
#
class jmxtrans inherits jmxtrans::params {
  case $::operatingsystem {
    'RedHat', 'CentOS': {
      $pkg_provider       = 'rpm'
      $package_name       = "jmxtrans_${jmxtrans::params::version}.noarch.rpm"
      $tmpsource          = "/tmp/${package_name}"
      $defaults_file_path = '/etc/sysconfig/jmxtrans'
    }
    'Debian', 'Ubuntu': {
      $pkg_provider       = 'dpkg'
      $package_name       = "jmxtreans_${jmxtrans::params::version}_all.deb"
      $tmpsource          = "/tmp/${package_name}"
      $defaults_file_path = '/etc/default/jmxtrans'
    }
    default: {
      fail("${module_name} provides no package for ${::operatingsystem}")
    }
  }

  file { $tmpsource:
    ensure  => present,
    source  => "puppet:///modules/${module_name}/${package_name}",
    backup  => false,
    owner   => 'root',
    group   => 'root',
    before  => package[$package_name]
  }

  package { $package_name:
    ensure    => installed,
    source    => $tmpsource,
    provider  => $pkg_provider
  }

  service { "jmxtrans":
    enable      => true,
    ensure      => running,
    hasrestart  => true,
    hasstatus   => true,
    require     => Package[$package_name]
  }
}