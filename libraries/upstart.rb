module CernerTomcat
  module ServiceProviders
    class CernerTomcatUpstart < PoiseService::ServiceProviders::Upstart
      provides(:cerner_tomcat_upstart)

      def action_enable
        # Overriding this method so the service is not started as a side effect of being enabled
        include_recipe(*Array(recipes)) if recipes
        notifying_block do
          create_service
        end
        enable_service
      end
    end
  end
end
