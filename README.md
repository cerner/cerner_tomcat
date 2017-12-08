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

 * Chef 12+

### Cookbooks

 * java
 * ulimit
 * logrotate
 * poise
 * poise-archive

Usage
-----

The cookbook provides a resource for you to use to install and configure tomcat.

The `cerner_tomcat` resource has support for `remote_file`, `cookbook_file`, and `template` as sub-resources of the cerner_tomcat resource. When using these sub-resources, the parent `cerner_tomcat` resource's path, user, group and sensitive properties are provided for free. These sub-resources can also be called from outside the `cerner_tomcat` block, if desired, by prepending `cerner_tomcat_` to the resource call and provided a `parent` property.

Example:
```ruby
cerner_tomcat 'my_tomcat' do
  # resource config
end

cerner_tomcat_remote_file do
   parent 'my_tomcat'
   source '...'
end
```

`cerner_tomcat` delays restart, when necessary, for the end of the main converge. This is in order to avoid restarting the service multiple times during a chef-client run. If any service dependencies are updated and require a service restart, this can be done by notifying the resource with a restart action.

Example:
```ruby
cerner_tomcat 'my_tomcat' do
  # resource config
end

dependent_resource 'dep' do
  # resource config
  notifies :restart, 'cerner_tomcat[my_tomcat]'
end
```

### cerner_tomcat

A resource for installing and configuring tomcat.

Actions: `:enable`, `:disable`, `:start`, `:stop`, `:restart`, `:reload` (default `:enable`)

Parameters:
 * `instance_name`: The name of the tomcat instance. (default = name of resource)
 * `user`: The user that will own and run the tomcat process (default = `tomcat`)
 * `group`: The group the tomcat user will be part of (default = `tomcat`)
 * `base_dir`: The path to the directory where the tomcat instance will be contained (default = `/opt/tomcat`)
 * `log_dir`: The path to the directory where the tomcat logs will be (default = `/var/log/tomcat`)
 * `log_rotate_options`: A hash or ruby block of options to configure log rotate. These will be merged with and override the defaults provided (view `libraries/cerner_tomcat.rb` for defaults)
 * `version`: The version of tomcat to install. This effectively builds the tomcat_url from a known URL (`repo1.maven.org`) with the given version (default=`8.0.21`)
 * `tomcat_url`: The URL to the tomcat binary used to install tomcat. This will override the url provided by `version`. NOTE: `version` needs to still be up to date in order to install tomcat properly
 * `shutdown_timeout`: The timeout used when trying to shutdown the tomcat service (default = `60`). If the timeout is reached, diagnostics are captured about the instance
 and the a force shutdown is applied.
 * `java_settings`: A Hash of java settings to be applied to the tomcat process (default = `{}`)
 * `env_vars`: A Hash of environment variables to be available when starting tomcat (default = `{}`)
 * `init_info`: A Hash or ruby block of options to configure the init script. These will be merged with and override the defaults provided (view `libraries/cerner_tomcat.rb` for defaults)
 * `install_java`: A boolean that indicates if we should try to install java (default=`true`)
 * `limits`: A Hash or ruby block of limits applied to the owner user of the tomcat process (default=`{ 'open_files' => 32_768, 'max_processes' => 1024 }`)
 * `create_user`: A boolean that indicates if the service user should be created (default=`true`)
 * `sensitive`: A boolean used to ensure sensitive resource data is not logged by the chef-client. Remote_file, cookbook_file, and template sub-resources can be overriden (default=true)
 * `service_manager`: The service management framework to use. Supported frameworks include `:sysvinit` and `:upstart`. If using `:upstart` then init_info, shutdown_timeout, and any provided health_checks will be ignored (default=`:sysvinit`)

Example:
``` ruby
cerner_tomcat "my_tomcat" do
  user "my_user"
  group "my_group"
  base_dir "/opt/my_dir"
  log_dir "/var/log/my_dir"
  log_rotate_options do
    frequency: 'daily'
    size: '10M'
    maxsize: '100M'
  end
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

#### health_check

A health check to be run when starting the tomcat service which uses HTTP to hit a web app's
health resource to verify it started correctly and is working. The name of the resource
should be the URL to your web app's health resource.

Parameters:

 * `http_method`: The HTTP method to use when running the health check (default=`GET`)
 * `backoff`: An array that indicates how back off should be handled, including the number of times and how long to wait before trying again (default=`[0, 5, 10, 30, 30, 60]`)
 * `time_bound`: The amount of time to wait before timing out a request (default=`3`)
 * `args`: Additional command line arguments to pass into cURL

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
be the context root to be used for the application. This sub-resource also accepts `cookbook_file`,
`remote_file`, and `template` sub-resources just like those listed above.

Parameters:
 * `source`: The URL to the war file of the application (required)
 * `checksum`: The SHA256 checksum of the war file of the application (optional)

Example:
``` ruby
cerner_tomcat "my_tomcat" do
  web_app "myApp" do
    source "http://myRepo.com/myApp-1.0.war"
    checksum "feccf30cad8aa5aea7a4e661ca9c32bab44d3df8ef5d97bd9c7eacf5c841bb17"

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

### Troubleshooting

The cookbook additionally configures a `diagnostic` command option as part of the `sysvinit` installation of the service. This command
captures various metrics of the JVM and bundles it in a `tar.gz` within a temp directory for later evaluation. Diagnostics which are
included in this bundle:

* JVM performance counters: Series of stats on the JVM, which are a lot of simple facts of the run-time at a low cost of acquiring
(filename: `<service_name>_perfcount.log`).
* JVM thread dump: Helpful to identify non-daemon threads and JVM information about each thread with their native thread ID
(filename: `<service_name>_thread_dump.log`).
* Native thread logs: Helpful to correlate CPU utilization to native threads which are tied to in the JVM thread dump with the 
native thread ID (nid). These are samplings from `top` which include native thread utilization (filename: `<service_name>_native_thread.log`).
* JVM GC class histogram: Helpful if JVM seems hung, and identified GC threads are utilizing high CPU, to then evaluate the amount 
of objects / types being created (filename: `<service_name>_gc_class_histogram.log`).

If using the `sysvinit` installation of the service, and the Tomcat service does not shutdown in a timely manner (within the defined 
timeout period), it will include a thread dump as part of the service stdout (ex. `catalina.out`), and may additionally invoke this
diagnostic bundle to be created before forcing the service process to shutdown (through an OS signal). This can be helpful to further
evaluate if a service is consistently requiring a forceful shutdown (web application may have a non-daemon thread not being shutdown).

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
