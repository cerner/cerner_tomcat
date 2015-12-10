
cerner_tomcat 'my_tomcat' do
  user 'my_user'
  group 'my_group'
  base_dir '/opt/my_dir'
  log_dir '/opt/my_logs'
  log_rotate_options('rotate' => 1)
  env_vars('TEST_VAR' => 'TEST_VALUE')
  java_settings('-Xms' => '512m',
                '-Xmx' => '512m',
                '-XX:PermSize=' => '384m',
                '-XX:MaxPermSize=' => '384m')
  init_info('Thing' => 'Value', 'Default-Start' => '1 2 3 4 5')

  cookbook_file 'my_file' do
    source 'my_file'
  end

  remote_file 'my_remote_file' do
    source 'https://gist.github.com/bbaugher/31950ed43f0ab0eab788'
  end

  template 'my_template' do
    source 'my_template.erb'
    variables(key: 'tomcat_my_template')
  end

  health_check 'http://localhost:8080/my_webapp/hello'

  web_app 'my_webapp' do
    source 'http://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/sample.war'

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
