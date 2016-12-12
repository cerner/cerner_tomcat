module CernerTomcat
  module ServiceProviders
    class CernerTomcatSysvinit < PoiseService::ServiceProviders::Sysvinit
      provides(:cerner_tomcat_sysvinit)

      def action_enable
        # Overriding this method so the service is not started as a side effect of being enabled
        include_recipe(*Array(recipes)) if recipes
        notifying_block do
          create_service
        end
        enable_service
      end

      def service_resource
        @service_resource ||= Chef::Resource::Service.new("tomcat_#{new_resource.service_name}", run_context).tap do |r|
          r.enclosing_provider = self
          r.source_line = new_resource.source_line
          r.supports(status: true, restart: true, reload: true)
        end
      end
    end
  end
end
