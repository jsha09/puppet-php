# PHP globals class
#
# === Parameters
#
# [*php_version*]
#   The version of php.
#
# [*config_root*]
#   The configuration root directory.
#
# [*fpm_pid_file*]
#   Path to pid file for fpm
#
# [*rhscl_mode*]
#   The mode specifies the specifics in paths for the various RedHat SCL environments so that the module is configured
#   correctly on their pathnames.
#
#   Valid modes are: 'rhscl', 'remi'
#

class php::globals (
  $php_version  = undef,
  $config_root  = undef,
  $fpm_pid_file = undef,
  $rhscl_mode   = undef,
) {
  if $php_version != undef {
    if $rhscl_mode {
      validate_re($php_version, '^(rh-)?php[57][0-9]')
    }
    else {
      validate_re($php_version, '^[57].[0-9]')
    }
  }
  if $config_root != undef {
    validate_absolute_path($config_root)
  }

  if $fpm_pid_file != undef {
    validate_absolute_path($fpm_pid_file)
  }

  $default_php_version = $::osfamily ? {
    'Debian' => $::operatingsystem ? {
      'Ubuntu' => $::operatingsystemrelease ? {
        /^(16.04)$/ => '7.0',
        default => '5.x',
      },
      default => '5.x',
    },
    default => '5.x',
  }

  $globals_php_version = pick($php_version, $default_php_version)

  case $::osfamily {
    'Debian': {
      if $::operatingsystem == 'Ubuntu' {
        case $globals_php_version {
          /^5\.4/: {
            $default_config_root = '/etc/php5'
            $default_fpm_pid_file = "/var/run/php/php${globals_php_version}-fpm.pid"
            $fpm_error_log = '/var/log/php5-fpm.log'
            $fpm_service_name = 'php5-fpm'
            $ext_tool_enable = '/usr/sbin/php5enmod'
            $ext_tool_query = '/usr/sbin/php5query'
            $package_prefix = 'php5-'
          }
          /^[57].[0-9]/: {
            $default_config_root = "/etc/php/${globals_php_version}"
            $default_fpm_pid_file = "/var/run/php/php${globals_php_version}-fpm.pid"
            $fpm_error_log = "/var/log/php${globals_php_version}-fpm.log"
            $fpm_service_name = "php${globals_php_version}-fpm"
            $ext_tool_enable = "/usr/sbin/phpenmod -v ${globals_php_version}"
            $ext_tool_query = "/usr/sbin/phpquery -v ${globals_php_version}"
            $package_prefix = "php${globals_php_version}-"
          }
          default: {
            # Default php installation from Ubuntu official repository use the following paths until 16.04
            # For PPA please use the $php_version to override it.
            $default_config_root = '/etc/php5'
            $default_fpm_pid_file = '/var/run/php5-fpm.pid'
            $fpm_error_log = '/var/log/php5-fpm.log'
            $fpm_service_name = 'php5-fpm'
            $ext_tool_enable = '/usr/sbin/php5enmod'
            $ext_tool_query = '/usr/sbin/php5query'
            $package_prefix = 'php5-'
          }
        }
      } else {
        case $globals_php_version {
          /^7/: {
            $default_config_root = "/etc/php/${globals_php_version}"
            $default_fpm_pid_file = "/var/run/php/php${globals_php_version}-fpm.pid"
            $fpm_error_log = "/var/log/php${globals_php_version}-fpm.log"
            $fpm_service_name = "php${globals_php_version}-fpm"
            $ext_tool_enable = "/usr/sbin/phpenmod -v ${globals_php_version}"
            $ext_tool_query = "/usr/sbin/phpquery -v ${globals_php_version}"
            $package_prefix = 'php7.0-'
          }
          default: {
            $default_config_root = '/etc/php5'
            $default_fpm_pid_file = '/var/run/php5-fpm.pid'
            $fpm_error_log = '/var/log/php5-fpm.log'
            $fpm_service_name = 'php5-fpm'
            $ext_tool_enable = '/usr/sbin/php5enmod'
            $ext_tool_query = '/usr/sbin/php5query'
            $package_prefix = 'php5-'
          }
        }
      }
    }
    'Suse': {
      case $globals_php_version {
        /^7/: {
          $default_config_root = '/etc/php7'
          $package_prefix = 'php7-'
          $default_fpm_pid_file = '/var/run/php7-fpm.pid'
          $fpm_error_log = '/var/log/php7-fpm.log'
        }
        default: {
          $default_config_root = '/etc/php5'
          $package_prefix = 'php5-'
          $default_fpm_pid_file = '/var/run/php5-fpm.pid'
          $fpm_error_log = '/var/log/php5-fpm.log'
        }
      }
    }
    'RedHat': {
      case $rhscl_mode {
        'remi': {
          $rhscl_root             = "/opt/remi/${php_version}/root"
          $default_config_root    = "${rhscl_root}/etc"
          $default_fpm_pid_file   = "${rhscl_root}/var/run/php-fpm/php-fpm.pid"
          $package_prefix         = "${php_version}-php-"
          $fpm_service_name       = "${php_version}-php-fpm"
        }
        'rhscl': {
          $rhscl_root             = "/opt/rh/${php_version}/root"
          $default_config_root    = "/etc/opt/rh/${php_version}" # rhscl registers contents by copy in /etc/opt/rh
          $default_fpm_pid_file   = "/var/opt/rh/${php_version}/run/php-fpm/php-fpm.pid"
          $package_prefix         = "${php_version}-php-"
          $fpm_service_name       = "${php_version}-php-fpm"
        }
        undef: {
          $default_config_root    = '/etc/php.d'
          $default_fpm_pid_file   = '/var/run/php-fpm/php-fpm.pid'
          $fpm_service_name       = undef
          $package_prefix         = undef
        }
        default: {
          fail("Unsupported rhscl_mode '${rhscl_mode}'")
        }
      }
    }
    'FreeBSD': {
      $default_config_root  = '/usr/local/etc'
      $default_fpm_pid_file = '/var/run/php-fpm.pid'
      $fpm_service_name     = undef
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily}")
    }
  }

  $globals_config_root    = pick($config_root, $default_config_root)
  $globals_fpm_pid_file   = pick($fpm_pid_file, $default_fpm_pid_file)
}
