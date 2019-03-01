maintainer 'Cerner Corp'
maintainer_email 'Bryan.Baugher@Cerner.com'
license 'Apache-2.0'
description 'Installs/Configures tomcat'
long_description 'This cookbook is meant to install and configure an instance of tomcat'
issues_url 'https://github.com/cerner/cerner_tomcat/issues'
source_url 'https://github.com/cerner/cerner_tomcat'
name 'cerner_tomcat'

chef_version '>= 12.0' if respond_to?(:chef_version)

supports 'centos'
supports 'ubuntu'

depends 'java', '>= 1.42'
depends 'ulimit', '~> 0.3'
depends 'logrotate'
depends 'poise', '~> 2.4'
depends 'poise-archive', '~> 1.2'
depends 'poise-service', '~> 1.4'
depends 'compat_resource', '>= 12.16'

version '3.5.0'
