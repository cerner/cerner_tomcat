# coding: UTF-8
def initialize(*args)
  super

  @cookbook_files = []
  @remote_files = []
  @templates = []
  @web_apps = []
  @health_checks = []
end

actions(:install, :uninstall)
default_action :install

attribute :instance_name,      kind_of: String,  name_attribute: true
attribute :user,               kind_of: String,  default: 'tomcat'
attribute :group,              kind_of: String,  default: 'tomcat'
attribute :base_dir,           kind_of: String,  default: '/opt/tomcat'
attribute :log_dir,            kind_of: String,  default: '/var/log/tomcat'
attribute :log_rotate_options, kind_of: Hash,    default: {}
attribute :version,            kind_of: String,  default: '8.0.21'
attribute :tomcat_url,         kind_of: String,  default: nil
attribute :shutdown_timeout,   kind_of: Integer, default: 60
attribute :java_settings,      kind_of: Hash,    default: {}
attribute :env_vars,           kind_of: Hash,    default: {}
attribute :init_info,          kind_of: Hash,    default: {}
attribute :install_java,       kind_of: [TrueClass, FalseClass],    default: true
attribute :limits,             kind_of: Hash,    default: {}
attribute :start_on_install,   kind_of: [TrueClass, FalseClass],    default: true
attribute :create_user,        kind_of: [TrueClass, FalseClass],    default: true

def cookbook_file(file_path, &block)
  cookbook_file = ::CernerTomcat::CookbookFileBlock.new(file_path)
  cookbook_file.evaluate(&block)
  @cookbook_files << cookbook_file
end

def remote_file(file_path, &block)
  remote_file = ::CernerTomcat::RemoteFileBlock.new(file_path)
  remote_file.evaluate(&block)
  @remote_files << remote_file
end

def template(file_path, &block)
  template = ::CernerTomcat::TemplateBlock.new(file_path)
  template.evaluate(&block)
  @templates << template
end

def web_app(name, &block)
  web_app = ::CernerTomcat::WebAppBlock.new(name)
  web_app.evaluate(&block)
  @web_apps << web_app
end

def health_check(uri, &block)
  health_check_block = ::CernerTomcat::HealthCheckBlock.new(uri)
  health_check_block.evaluate(&block)
  @health_checks << health_check_block
end

attr_reader :cookbook_files
attr_reader :remote_files
attr_reader :templates
attr_reader :web_apps
attr_reader :health_checks
