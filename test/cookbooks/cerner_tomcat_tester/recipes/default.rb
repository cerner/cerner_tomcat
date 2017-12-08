
# The kitchen tests are configuring the manage the user outside of cerner_tomcat.
# As a result, we will manage it separately from the provider.
tomcat_user = 'my_user'
tomcat_group = 'my_group'

# Setup user/group
group tomcat_group do
  action :create
end

user tomcat_user do
  gid tomcat_group
  home "/home/#{tomcat_user}"
  manage_home true
end

cerner_tomcat 'my_tomcat' do
  user tomcat_user
  group tomcat_group
  base_dir '/opt/my_dir'
  log_dir '/opt/my_logs'
  log_rotate_options('rotate' => 1)
  env_vars('TEST_VAR' => 'TEST_VALUE')
  java_settings('-Xms' => '512m',
                '-Xmx' => '512m',
                '-XX:PermSize=' => '384m',
                '-XX:MaxPermSize=' => '384m')
  init_info('Thing' => 'Value', 'Default-Start' => '1 2 3 4 5')
  limits(
    'open_files' => 65_536,
    'max_processes' => 4096
  )

 cookbook_file 'my_file' do
    source 'my_file'
    mode '0767'

    # we can increase sleep to force a timeout and demonstrate this behavior works
    only_if 'sleep 1', timeout: 3

    # evaluates to false since "5" is not a valid command line option
    not_if 'ls -5'
  end

  cookbook_file 'only_if_skipped_cookbook_file' do
    source 'my_file'
    only_if { false }
  end

  cookbook_file 'not_if_skipped_cookbook_file' do
    source 'my_file'
    not_if { true }
  end

  remote_file 'my_remote_file' do
    source 'https://gist.github.com/bbaugher/31950ed43f0ab0eab788'
    mode '0747'

    # we can increase sleep to force a timeout and demonstrate this behavior works
    only_if 'sleep 1', timeout: 3

    # evaluates to false since "5" is not a valid command line option
    not_if 'ls -5'
  end

  remote_file 'only_if_skipped_remote_file' do
    source 'https://gist.github.com/bbaugher/31950ed43f0ab0eab788'
    only_if { false }
  end

  remote_file 'not_if_skipped_remote_file' do
    source 'https://gist.github.com/bbaugher/31950ed43f0ab0eab788'
    not_if { true }
  end

  remote_file 'multiple_not_if_skipped_remote_file' do
    source 'https://gist.github.com/bbaugher/31950ed43f0ab0eab788'
    not_if { false }
    not_if { true }
  end

  template 'my_template' do
    source 'my_template.erb'
    variables(key: 'tomcat_my_template')
    mode '0707'

    # we can increase sleep to force a timeout and demonstrate this behavior works
    only_if 'sleep 1', timeout: 3

    # evaluates to false since "5" is not a valid command line option
    not_if 'ls -5'
  end

  template 'only_if_skipped_template' do
    source 'my_template.erb'
    variables(key: 'tomcat_my_template')
    only_if { false }
  end

  template 'not_if_skipped_template' do
    source 'my_template.erb'
    variables(key: 'tomcat_my_template')
    not_if { true }
  end

  template 'conf/server.xml' do
    source 'server.xml.erb'
    variables(
      'port' => {
        'connector' => 8001,
        'shutdown' => 8002,
        'ajp' => 8003,
      })
  end

  health_check 'http://localhost:8001/my_webapp/hello'

  web_app 'my_webapp' do
    source 'http://tomcat.apache.org/tomcat-8.0-doc/appdev/sample/sample.war'
    checksum '89b33caa5bf4cfd235f060c396cb1a5acb2734a1366db325676f48c5f5ed92e5'

    cookbook_file 'my_file' do
      source 'my_file'
    end

    remote_file 'my_remote_file' do
      source 'https://gist.github.com/bbaugher/31950ed43f0ab0eab788'
    end

    template 'my_template' do
      source 'my_template.erb'
      variables(key: 'web_app_template')
    end
  end
end

# Including a secondary instance to test delay service starting
# between installations
cerner_tomcat 'my_tomcat_2' do
  user tomcat_user
  group tomcat_group
  base_dir '/opt/my_dir'
  log_dir '/opt/my_logs'
  log_rotate_options('rotate' => 1)
  env_vars('TEST_VAR' => 'TEST_VALUE')
  java_settings('-Xms' => '512m',
                '-Xmx' => '512m',
                '-XX:PermSize=' => '384m',
                '-XX:MaxPermSize=' => '384m')
  init_info('Thing' => 'Value', 'Default-Start' => '1 2 3 4 5')
  limits(
    'open_files' => 65_536,
    'max_processes' => 4096
  )
  create_user false
  service_manager :upstart

  health_check 'http://localhost:8011/my_webapp/hello' do
    args '-k'
  end

  web_app 'my_webapp' do
    source 'http://tomcat.apache.org/tomcat-8.0-doc/appdev/sample/sample.war'
    checksum '89b33caa5bf4cfd235f060c396cb1a5acb2734a1366db325676f48c5f5ed92e5'
  end
end

# we know this file landed if the service is able to succesfully start
cerner_tomcat_template 'conf/server.xml' do
  parent 'my_tomcat_2'
  source 'server.xml.erb'
  variables(
    'port' => {
      'connector' => 8011,
      'shutdown' => 8012,
      'ajp' => 8013,
    })
end

cerner_tomcat_web_app 'my_webapp' do
  parent 'my_tomcat_2'
  source 'http://tomcat.apache.org/tomcat-8.0-doc/appdev/sample/sample.war'
  checksum '89b33caa5bf4cfd235f060c396cb1a5acb2734a1366db325676f48c5f5ed92e5'
  cookbook_file 'my_file' do
    source 'my_file'
  end
end
