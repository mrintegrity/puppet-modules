#
# Tomcat 6
#

class tomcat {

    include java
    include munin

    package {
        [ "tomcat6",
        "tomcat6-admin",
        "tomcat6-common",
        "tomcat6-user",
        "tomcat6-docs",
        "libmysql-java",
        "munin-java-plugins" ]:
        ensure => "installed"
    }

    # Allow access to munin plugins
    file { "/etc/tomcat6/tomcat-users.xml":
        ensure => "present",
        content => "<user username='munin' password='munin' roles='standard,manager'/>",
        owner => "root",
        group => "root",
        require => Package["tomcat6"],
    }

    # Just to disable console logging that fills up catalina.out
    # log file with useless junk
    file { "/etc/tomcat6/logging.properties":
        ensure => "present",
        source => "puppet:///modules/tomcat/logging.properties",
        owner  => "root",
        group  => "root",
        require => Package["tomcat6"],
    }

    munin::plugin {
        [ "tomcat_jvm", "tomcat_threads", "tomcat_volume", "tomcat_access" ]:
        ensure => "present",
        require => Package["munin-java-plugins"],
    }

    service { "tomcat6":
       ensure => "running",
       require => [
          Package["tomcat6"],
          File["/etc/tomcat6/tomcat-users.xml"],
          File["/etc/tomcat6/logging.properties"]
       ],
       subscribe => Package["tomcat6"],
    }

}

