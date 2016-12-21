Change Log
==========

[3.0.0 - 12-21-2016](https://github.com/cerner/cerner_tomcat/issues?milestone=6&state=closed)
---------------------------------------------------------------------------------------------

  * [Enhancement] [Issue-22](https://github.com/cerner/cerner_tomcat/issues/22) : Upgrade off init to upstart/systemd/etc
  * [Bug] [Issue-21](https://github.com/cerner/cerner_tomcat/issues/21) : find_pid within init.d script can qualify different Tomcat installations 
  * [Enhancement] [Issue-4](https://github.com/cerner/cerner_tomcat/issues/4) : Sub resources should provide all options (remote_file, cookbook_file, template)

[2.3.0 - 10-26-2016](https://github.com/cerner/cerner_tomcat/issues?milestone=4&state=closed)
---------------------------------------------------------------------------------------------

  * [Bug] [Issue-26](https://github.com/cerner/cerner_tomcat/issues/26) : Install block has unnecessary not_if guard
  * [Enhancement] [Issue-25](https://github.com/cerner/cerner_tomcat/issues/25) : Adding additional properties to sub resources
  * [Enhancement] [Issue-23](https://github.com/cerner/cerner_tomcat/issues/23) : Support additional command line options for health checks
  * [Enhancement] [Issue-15](https://github.com/cerner/cerner_tomcat/issues/15) : Add a flag to disable user/group creation

[2.2.0 - 09-13-2016](https://github.com/cerner/cerner_tomcat/issues?milestone=3&state=closed)
---------------------------------------------------------------------------------------------

  * [Enhancement] [Issue-17](https://github.com/cerner/cerner_tomcat/issues/17) : ulimit settings are hard-coded in the provider
  * [Enhancement] [Issue-16](https://github.com/cerner/cerner_tomcat/issues/16) : Reduce the number of service start-up events on a single chef-client execution

[2.1.1 - 05-02-2016](https://github.com/cerner/cerner_tomcat/issues?milestone=2&state=closed)
---------------------------------------------------------------------------------------------

  * [Bug] [Issue-9](https://github.com/cerner/cerner_tomcat/issues/9) : Restart service on java setting changes
  * [Bug] [Issue-8](https://github.com/cerner/cerner_tomcat/issues/8) : Uninstall action needs recursive property to delete tomcat instance
