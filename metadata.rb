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

depends 'java'
depends 'ulimit'
depends 'logrotate'

version '2.3.0'
