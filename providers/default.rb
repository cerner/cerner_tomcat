
use_inline_resources

action :install do
  install_dir = ::File.join(new_resource.base_dir, new_resource.instance_name)
  log_dir = ::File.join(new_resource.log_dir, new_resource.instance_name)
  tomcat_url = new_resource.tomcat_url.nil? ? "http://repo1.maven.org/maven2/org/apache/tomcat/tomcat/#{new_resource.version}/tomcat-#{new_resource.version}.tar.gz" : new_resource.tomcat_url
  tomcat_file = "cerner_tomcat_#{new_resource.instance_name}-apache-tomcat.tar.gz"

  # Install java
  run_context.include_recipe 'java' if new_resource.install_java

  # Ensure curl is installed if we have any health checks
  package "curl_#{new_resource.instance_name}" do
    action :install
    package_name 'curl'
    not_if { new_resource.health_checks.empty? }
  end

  # Setup user/group
  group new_resource.group do
    action :create
    notifies :restart, "service[tomcat_#{new_resource.instance_name}]"
  end

  user new_resource.user do
    gid new_resource.group
    notifies :restart, "service[tomcat_#{new_resource.instance_name}]"
  end

  limits_defaults = { 'open_files' => 32_768, 'max_processes' => 1024 }
  limits_options = limits_defaults.merge(new_resource.limits)

  user_ulimit new_resource.user do
    filehandle_limit limits_options['open_files']
    process_limit limits_options['max_processes']
  end

  # From the requirements of the cookbook:
  # If you're on Ubuntu, you'll also need to add recipe[ulimit] to your 
  # runlist, or the files created by this cookbook will be ignored
  run_context.include_recipe 'ulimit'

  # Create base directory
  directory new_resource.base_dir do
    action :create
    owner new_resource.user
    group new_resource.group
    mode '0755'
    recursive true
  end

  # Download tomcat
  remote_file "#{Chef::Config[:file_cache_path]}/#{tomcat_file}" do
    source tomcat_url
    owner new_resource.user
    group new_resource.group
    mode '0755'
    backup false

    notifies :run, "bash[install_tomcat_#{new_resource.instance_name}]", :immediately
  end

  # Install tomcat
  bash "install_tomcat_#{new_resource.instance_name}" do
    action :nothing
    cwd new_resource.base_dir

    code <<-EOH
      rm -rf #{new_resource.instance_name}
      tar zxf #{Chef::Config[:file_cache_path]}/#{tomcat_file}
      mv apache-tomcat-#{new_resource.version} #{new_resource.instance_name}
      rm -rf #{new_resource.instance_name}/webapps/*
    EOH

    not_if do
      ::File.exist?(install_dir)
    end
  end

  directory new_resource.log_dir do
    action :create
    owner new_resource.user
    group new_resource.group
    mode '0755'
    recursive true
  end

  # Link tomcat log files into /var/log/tomcat/[instanceName]
  link log_dir do
    to "#{install_dir}/logs"
    owner new_resource.user
    group new_resource.group
    mode '0755'
  end

  log_rotate_defaults = {
    'path' => [],
    'frequency' => 'daily',
    'rotate' => 3,
    'options' => %w(notifempty copytruncate compress),
    'size' => '10M',
    'maxsize' => '100M'
  }

  # Merge our defaults with consumers options
  log_rotate_options = log_rotate_defaults.merge(new_resource.log_rotate_options)

  # Ensure the right paths are always added
  log_rotate_options['path'] += ["#{log_dir}/*.out", "#{log_dir}/*.log"]

  # Add log rotate config for tomcat
  logrotate_app "tomcat-#{new_resource.instance_name}" do
    log_rotate_options.each do |k, v|
      send k, v
    end
  end

  init_info_defaults = {
    'Provides' => @new_resource.instance_name,
    'Short-Description' => "#{@new_resource.instance_name} tomcat server",
    'Default-Start' => '3 4 5',
    'Default-Stop' => '0 1 2 6',
    'Required-Start' => '',
    'Required-Stop' => '',
    'Should-Start' => '',
    'Should-Stop' => ''
  }

  init_info = init_info_defaults.merge(new_resource.init_info)

  # Sync/Add tomcat init.d script
  template "/etc/init.d/tomcat_#{new_resource.instance_name}" do
    source 'tomcat_init.sh.erb'
    cookbook 'cerner_tomcat'
    mode '0755'
    backup false
    variables(new_resource: new_resource, init_info: init_info)
  end

  # Configure environment vars and java settings
  template "#{install_dir}/bin/setenv.sh" do
    source 'setenv.sh.erb'
    cookbook 'cerner_tomcat'
    mode '0755'
    backup false
    sensitive true if Chef::Resource::User.method_defined? :sensitive
    variables(
      env_vars: new_resource.env_vars,
      java_settings: new_resource.java_settings
    )
    notifies :restart, "service[tomcat_#{new_resource.instance_name}]"
  end

  # Install web apps
  new_resource.web_apps.each do |web_app|
    web_app_dir = "#{install_dir}/webapps/#{web_app.name}"

    directory web_app_dir do
      owner new_resource.user
      group new_resource.group
      mode '0755'
    end

    execute "delete #{new_resource.instance_name} web app #{web_app.name}" do
      action :nothing
      command "rm -rf #{web_app_dir}/*"
    end

    war_file_path = "#{web_app_dir}.war"

    # Download war file
    remote_file war_file_path do
      source web_app.source
      owner new_resource.user
      group new_resource.group
      mode '0755'
      backup false

      notifies :stop, "service[tomcat_#{new_resource.instance_name}]", :immediately
      notifies :run, "execute[delete #{new_resource.instance_name} web app #{web_app.name}]", :immediately
      notifies :restart, "service[tomcat_#{new_resource.instance_name}]"
    end

    # Explode war
    execute "jar xf #{war_file_path}" do
      cwd web_app_dir
      only_if do
        Dir.entries(web_app_dir).delete_if { |v| v == '.' || v == '..' }.empty?
      end
    end

    # Install any webapp cookbook files
    web_app.cookbook_files.each do |cookbook_file_block|
      tomcat_cookbook_file new_resource, web_app_dir, cookbook_file_block
    end

    # Install any webapp remote files
    web_app.remote_files.each do |remote_file_block|
      tomcat_remote_file new_resource, web_app_dir, remote_file_block
    end

    # Install any webapp templates
    web_app.templates.each do |template_block|
      tomcat_template new_resource, web_app_dir, template_block
    end
  end

  # Install cookbook files
  new_resource.cookbook_files.each do |cookbook_file_block|
    tomcat_cookbook_file new_resource, install_dir, cookbook_file_block
  end

  # Install remote files
  new_resource.remote_files.each do |remote_file_block|
    tomcat_remote_file new_resource, install_dir, remote_file_block
  end

  # Install templates
  new_resource.templates.each do |template_block|
    tomcat_template new_resource, install_dir, template_block
  end

  # Ensure all the files have the correct permissions
  execute "chown -R #{new_resource.user}:#{new_resource.group} #{install_dir}" do
    action :run
  end

  # Enable tomcat instance, :enable adds service to startup,
  # :start starts service if it isn't already started. 
  # :start will be conditionally applied, as the service restart will
  # always be restarted at the end of convergence if any file that
  # requires service restart is triggered.
  service_actions = [:enable]
  service_actions << :start if new_resource.start_on_install
  service "tomcat_#{new_resource.instance_name}" do
    supports status: true, restart: true
    action service_actions
  end
end

action :uninstall do
  # Since we are recusively deleting directories guard against empty string which
  # could result in deleting more then what we want
  fail "base_dir cannot be empty string" if new_resource.base_dir.empty?
  fail "instance_name cannot be empty string" if new_resource.instance_name.empty?
  fail "log_dir cannot be empty string" if new_resource.log_dir.empty?

  service "tomcat_#{new_resource.instance_name}" do
    supports status: true, restart: true
    action [:disable, :stop]
  end

  directory "#{new_resource.base_dir}/#{new_resource.instance_name}" do
    action :delete
    recursive true
  end

  file "#{new_resource.log_dir}/#{new_resource.instance_name}" do
    action :delete
  end

  file "/etc/init.d/tomcat_#{new_resource.instance_name}" do
    action :delete
  end
end

def tomcat_template(new_resource, path, template_block)
  file_path = ::File.join(path, template_block.file_path)

  create_parent_directory new_resource, file_path

  template file_path do
    source template_block.source
    owner new_resource.user
    group new_resource.group
    mode '0750'
    backup false
    sensitive true if Chef::Resource::User.method_defined? :sensitive
    cookbook template_block.cookbook unless template_block.cookbook.nil?
    variables template_block.variables unless template_block.variables.nil?
    notifies :restart, "service[tomcat_#{new_resource.instance_name}]"
  end
end

def tomcat_cookbook_file(new_resource, path, cookbook_file_block)
  file_path = ::File.join(path, cookbook_file_block.file_path)

  create_parent_directory new_resource, file_path

  cookbook_file file_path do
    source cookbook_file_block.source
    owner new_resource.user
    group new_resource.group
    mode '0750'
    backup false
    sensitive true if Chef::Resource::User.method_defined? :sensitive
    cookbook cookbook_file_block.cookbook unless cookbook_file_block.cookbook.nil?
    notifies :restart, "service[tomcat_#{new_resource.instance_name}]"
  end
end

def tomcat_remote_file(new_resource, path, remote_file_block)
  file_path = ::File.join(path, remote_file_block.file_path)

  create_parent_directory new_resource, file_path

  remote_file file_path do
    source remote_file_block.source
    owner new_resource.user
    group new_resource.group
    mode '0750'
    backup false
    sensitive true if Chef::Resource::User.method_defined? :sensitive
    notifies :restart, "service[tomcat_#{new_resource.instance_name}]"
  end
end

def create_parent_directory(new_resource, path)
  directory ::File.expand_path(::File.join(path, '..')) do
    owner new_resource.user
    group new_resource.group
    mode '0755'
    recursive true
  end
end
