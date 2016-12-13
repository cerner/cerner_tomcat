# coding: UTF-8

require 'spec_helper'

describe user('my_user') do
  it { should exist }
  it { should belong_to_group 'my_group' }
  it { should have_home_directory '/home/my_user' }
end

describe service('my_tomcat') do
  it { should be_running   }
end

describe service('my_tomcat_2') do
  it { should be_running   }
end

# Verify both of the services running (2 of them)
describe process('java') do
  its(:count) { should eq 2 }
  its(:user)  { should eq 'my_user' }
  its(:args)  { should match /-Xms512m -Xmx512m -XX:PermSize=384m -XX:MaxPermSize=384m/ }
end

describe file('/opt/my_dir/my_tomcat/my_file') do
  it { should be_file }
  it { should be_owned_by 'my_user' }
  it { should be_grouped_into 'my_group' }
  it { should be_mode 767 }
end

describe file('/opt/my_dir/my_tomcat/only_if_skipped_cookbook_file') do
  it { should_not exist }
end

describe file('/opt/my_dir/my_tomcat/not_if_skipped_cookbook_file') do
  it { should_not exist }
end

describe file('/opt/my_dir/my_tomcat/my_remote_file') do
  it { should be_file }
  it { should be_owned_by 'my_user' }
  it { should be_grouped_into 'my_group' }
  it { should be_mode 747 }
end

describe file('/opt/my_dir/my_tomcat/only_if_skipped_remote_file') do
  it { should_not exist }
end

describe file('/opt/my_dir/my_tomcat/not_if_skipped_remote_file') do
  it { should_not exist }
end

describe file('/opt/my_dir/my_tomcat/multiple_not_if_skipped_remote_file') do
  it { should_not exist }
end

describe file('/opt/my_dir/my_tomcat/my_template') do
  it { should be_file }
  it { should be_owned_by 'my_user' }
  it { should be_grouped_into 'my_group' }
  it { should contain 'tomcat_my_template' }
  it { should be_mode 707 }
end

describe file('/opt/my_dir/my_tomcat/only_if_skipped_template') do
  it { should_not exist }
end

describe file('/opt/my_dir/my_tomcat/not_if_skipped_template') do
  it { should_not exist }
end

describe file('/opt/my_dir/my_tomcat/webapps/my_webapp') do
  it { should be_directory }
  it { should be_owned_by 'my_user' }
  it { should be_grouped_into 'my_group' }
end

describe file('/opt/my_dir/my_tomcat/webapps/my_webapp.war') do
  it { should be_file }
  it { should be_owned_by 'my_user' }
  it { should be_grouped_into 'my_group' }
end

describe file('/opt/my_dir/my_tomcat/webapps/my_webapp/my_file') do
  it { should be_file }
  it { should be_owned_by 'my_user' }
  it { should be_grouped_into 'my_group' }
end

describe file('/opt/my_dir/my_tomcat/webapps/my_webapp/my_remote_file') do
  it { should be_file }
  it { should be_owned_by 'my_user' }
  it { should be_grouped_into 'my_group' }
end

describe file('/opt/my_dir/my_tomcat/webapps/my_webapp/my_template') do
  it { should be_file }
  it { should be_owned_by 'my_user' }
  it { should be_grouped_into 'my_group' }
  it { should contain 'web_app_template' }
end

describe file('/opt/my_dir/my_tomcat_2/webapps/my_webapp.war') do
  it { should be_file }
  it { should be_owned_by 'my_user' }
  it { should be_grouped_into 'my_group' }
end

describe file('/opt/my_dir/my_tomcat_2/webapps/my_webapp/my_file') do
  it { should be_file }
  it { should be_owned_by 'my_user' }
  it { should be_grouped_into 'my_group' }
end

describe file('/opt/my_logs') do
  it { should be_directory }
  it { should be_owned_by 'my_user' }
  it { should be_grouped_into 'my_group' }
end

describe file('/opt/my_logs/my_tomcat') do
  it { should be_symlink }
  it { should be_linked_to '/opt/my_dir/my_tomcat/logs' }
  it { should be_owned_by 'my_user' }
  it { should be_grouped_into 'my_group' }
end

describe file('/etc/logrotate.d/tomcat-my_tomcat') do
  it { should contain '"/opt/my_logs/my_tomcat/*.out" "/opt/my_logs/my_tomcat/*.log" {' }
  it { should contain 'rotate 1' }
  it { should contain 'maxsize 100M' }
  it { should contain 'size 10M' }
  it { should contain 'daily' }
  it { should contain 'compress' }
  it { should contain 'copytruncate' }
end

describe file('/etc/init.d/tomcat_my_tomcat') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should contain '# Thing: Value' }
  it { should contain '# Default-Start: 1 2 3 4 5' }
  it { should contain '# Provides: my_tomcat' }
  it { should contain '# Default-Stop: 0 1 2 6' }
  it { should contain 'HC_CODE=$(healthCheck http://localhost:8001/my_webapp/hello GET 3 )' }
  it { should contain 'PID=`pgrep -u $USER -f "$CATALINA_HOME .*$START_CLASS"`' }
end

describe file('/etc/init/my_tomcat_2.conf') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should contain 'description "my_tomcat_2"' }
  it { should contain 'start on runlevel [2345]' }
  it { should contain 'stop on runlevel [!2345]' }
  it { should contain 'respawn limit 10 5' }
  it { should contain 'umask 022' }
  it { should contain 'chdir /opt/my_dir/my_tomcat_2' }
  it { should contain 'env CATALINA_HOME="/opt/my_dir/my_tomcat_2"' }
end

describe file('/opt/my_dir/my_tomcat/bin/setenv.sh') do
  it { should be_file }
  it { should be_owned_by 'my_user' }
  it { should be_grouped_into 'my_group' }
  it { should contain 'export TEST_VAR=TEST_VALUE' }
end

describe file('/etc/security/limits.d/my_user_limits.conf') do
  it { should be_file }
  it { should contain 'my_user - nofile 65536' }
  it { should contain 'my_user - nproc 4096' }
end
