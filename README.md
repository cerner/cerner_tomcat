Cerner Tomcat Cookbook
======================

[![Build Status](https://travis-ci.org/cerner/cerner_kafka.svg?branch=master)](https://travis-ci.org/cerner/cerner_tomcat)
[![Cookbook Version](https://img.shields.io/cookbook/v/cerner_tomcat.svg)](https://community.opscode.com/cookbooks/cerner_tomcat)

A Chef cookbook to install [Apache Tomcat](http://tomcat.apache.org/).

View the [Change Log](CHANGELOG.md) to see what has changed.

Requirements
------------

### Platforms

 * Ubuntu
 * CentOS

### Chef

 * Chef 11+

### Cookbooks

 * java
 * ulimit
 * logrotate

Usage
-----

The cookbook provides a resource for you to use to install and configure tomcat.

### cerner_tomcat

A resource for installing and configuring tomcat.

Actions: `:install`, `:uninstall` (default `:install`)

Parameters:
 * `instance_name`: The name of the tomcat instance. (default = name of resource)
 * `user`: The user that will own and run the tomcat process (default = `tomcat`)
 * `group`: The group the tomcat user will be part of (default = `tomcat`)
 * `base_dir`: The path to the directory where the tomcat instance will be contained (default = `/opt/tomcat`)
 * `log_dir`: The path to the directory where the tomcat logs will be (default = `/var/log/tomcat`)
 * `log_rotate_options`: A hash of options to configure log rotate. These will be merged with and override the defaults provided (view provider for defaults)
 * `version`: The version of tomcat to install. This effectively builds the tomcat_url from a known URL (`repo1.maven.org`) with the given version (default=`8.0.21`)
 * `tomcat_url`: The URL to the tomcat binary used to install tomcat. This will override the url provided by `version`. NOTE: `version` needs to still be up to date in order to install tomcat properly
 * `shutdown_timeout`: The timeout used when trying to shutdown the tomcat service (default = `60`)
 * `java_settings`: A Hash of java settings to be applied to the tomcat process (default = `{}`)
 * `env_vars`: A Hash of environment variables to be available when starting tomcat (default = `{}`)
 * `init_info`: A Hash of options to configure the init script. These will be merged with and override the defaults provided (view provider for defaults)
 * `install_java`: A boolean that indicates if we should try to install java (default=`true`)
 * `limits`: A Hash of limits applied to the owner user of the tomcat process (default=`{ 'open_files' => 32_768, 'max_processes' => 1024 }`)
 * `start_on_install`: A boolean that indicates if the service should be started immediately
 on installation. On a fresh installation, you generally will always restart the service
 process, so this may be used as a deployment optimization to avoid a start and later
 restart of the service (default=`true`).

Example:
``` ruby
cerner_tomcat "my_tomcat" do
  user "my_user"
  group "my_group"
  base_dir "/opt/my_dir"
  log_dir "/var/log/my_dir"
  log_rotate_options(
    'frequency' => 'daily',
    'size' => '10M',
    'maxsize' => '100M'
  )
  version "7.0.49"
  shutdown_timeout 120
  java_settings("-Xms" => "512m",
                 "-Xmx" => "512m",
                 "-XX:PermSize=" => "384m",
                 "-XX:MaxPermSize=" => "384m"
                 "-XX:+UseParNewGC" => "")
  env_vars("MY_VAR" => "MY_VALUE")
  init_info('Default-Start' => '1 2 3 4 5')
  install_java false
  limits(
    'open_files' => 32_768,
    'max_processes' => 1024
  )
end
```

Sub-Resource Parameters:

These parameters all take a block as their argument much like Chef's resources.

#### cookbook_file

A cookbook file to be included into the tomcat installation. The name of the sub-resource should be
a relative path to where the file should be included from the tomcat's installation directory. So
if you wanted a file in tomcat's lib directory its path should be `lib/myCookbookFile`.

Parameters:

 * `source`: The name of the cookbook file (required)
 * `cookbook`: The name of the cookbook to find the file (optional). Defaults to the cookbook calling the LWRP
 * `mode`: The permissions to set on the cookbook file (optional). Defaults to '750'
 * `only_if`: Use a chef only_if [guard](https://docs.chef.io/resource_common.html#guards] to only write the cookbook file if the statement evaluates to true (optional).
 * `not_if`: Use a chef not_if [guard](https://docs.chef.io/resource_common.html#guards] to not write the cookbook file if the statement evaluates to true (optional).

Example:
``` ruby
cerner_tomcat "my_tomcat" do
  cookbook_file "lib/mysql.jar" do
    source "mysql-5.12.jar"
    only_if { File.exists?('mysql-5.12.jar') }
    not_if { node['tomcat-service']['data_base_disabled'] }
  end
end
```

#### remote_file

A remote file to be included into the tomcat installation. The name of the sub-resource should be
a relative path to where the file should be included from the tomcat's installation directory. So
if you wanted a file in tomcat's lib directory its path should be `lib/myRemoteFile`.

Parameters:

 * `source`: The URL to use to download the remote file (required)
 * `mode`: The permissions to set on the remote file (optional). Defaults to '750'
 * `only_if`: Use a chef only_if [guard](https://docs.chef.io/resource_common.html#guards] to only write the remote file if the statement evaluates to true (optional).
 * `not_if`: Use a chef not_if [guard](https://docs.chef.io/resource_common.html#guards] to not write the remote file if the statement evaluates to true (optional).

Example:
``` ruby
cerner_tomcat "my_tomcat" do
  remote_file "lib/mysql.jar" do
    source "http://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.25/mysql-connector-java-5.1.25.jar"
    only_if { File.exists?('mysql-5.12.jar') }
    not_if { node['tomcat-service']['data_base_disabled'] }
  end
end
```

#### template

 A template to be included into the tomcat installation. The name of the sub-resource should be
a relative path to where the file should be included from the tomcat's installation directory. So
if you wanted a file in tomcat's lib directory its path should be `lib/myTemplate`.

Parameters:

 * `source`: The name of the template (required)
 * `cookbook`: The name of the cookbook to find the template (optional). Defaults to the cookbook calling the LWRP
 * `variables`: A hash of variables to be injected into the template (optional)
 * `mode`: The permissions to set on the template (optional). Defaults to '750'
 * `only_if`: Use a chef only_if [guard](https://docs.chef.io/resource_common.html#guards] to only write the template if the statement evaluates to true (optional).
 * `not_if`: Use a chef not_if [guard](https://docs.chef.io/resource_common.html#guards] to not write the template if the statement evaluates to true (optional).

Example:
``` ruby
cerner_tomcat "my_tomcat" do
  template "conf/dependency-conf.xml" do
    source "dependency-conf.xml.erb"
    variables {"myVar" => "myValue"}
    only_if { File.exists?('lib/dependency.jar') }
    not_if { node['tomcat-service']['dependency_conf_deployed'] }
  end
end
```

#### health_check

A health check to be run when starting the tomcat service which uses HTTP to hit a web app's
health resource to verify it started correctly and is working. The name of the resource
should be the URL to your web app's health resource.

Parameters:

 * `http_method`: The HTTP method to use when running the health check (default=`GET`)
 * `backoff`: An array that indicates how back off should be handled, including the number of times and how long to wait before trying again (default=`[0, 5, 10, 30, 30, 60]`)
 * `time_bound`: The amount of time to wait before timing out a request (default=`3`)

Example:
``` ruby
cerner_tomcat "my_tomcat" do
  # Uses defaults
  health_check "http://localhost:8080/myApp/health"

  health_check "http://localhost:8080/myApp/health" do
    http_method 'POST'
    backoff [0, 1, 2, 3]
    time_bound 5
  end
end
```

#### web_app

A web application to be included in the tomcat installation. The name of the sub-resource should
be the context root to be used for the application. This sub-resource also has `cookbook_file`,
`remote_file`, and `template` sub-resources just like those listed above.

Parameters:
 * `source`: The URL to the war file of the application (required)

Example:
``` ruby
cerner_tomcat "my_tomcat" do
  web_app "myApp" do
    source "http://myRepo.com/myApp-1.0.war"

    cookbook_file "WEB-INF/classes/app.properties" do
      source "app.properties"
    end

    remote_file "WEB-INF/lib/mysql.jar" do
      source "http://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.25/mysql-connector-java-5.1.25.jar"
    end

    template "WEB-INF/classes/log4j.properties" do
      source "log4j.properties.erb"
    end
  end
end
```

Contributing
------------

This project is licensed under the Apache License, Version 2.0.

When contributing to the project please add your name to the CONTRIBUTORS.txt file. Adding your name to the CONTRIBUTORS.txt file
signifies agreement to all rights and reservations provided by the License.

To contribute to the project execute a pull request through github. The pull request will be reviewed by the community and merged
by the project committers. Please attempt to conform to the test, code conventions, and code formatting standards if any
are specified by the project before submitting a pull request.

Releases
--------

Releases should happen regularly after most changes. Feel free to request a release by logging an issue.

Committers
----------

For information related to being a committer check [here](COMMITTERS.md).

LICENSE
-------

Copyright 2013 Cerner Innovation, Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0) Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
