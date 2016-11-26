# coding: UTF-8

maintainer 'Cerner Corp'
maintainer_email 'Bryan.Baugher@Cerner.com'
license 'All rights reserved'
description 'Installs/Configures tomcat'
long_description 'This cookbook is meant to install and configure an instance of tomcat'
issues_url 'https://github.com/cerner/cerner_tomcat/issues'
source_url 'https://github.com/cerner/cerner_tomcat'
name 'cerner_tomcat'

supports 'centos'
supports 'ubuntu'

depends 'java', '~> 1.42'
depends 'ulimit', '~> 0.4'
depends 'logrotate'
depends 'poise', '~> 2.4'
depends 'poise-archive', '~> 1.2'
depends 'compat_resource', '>= 12.16'

version '3.0.0'
