require_dependency 'admin_controller'
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

module IE
	module AdminControllerPatch
		
	    def self.included(base) # :nodoc:
			base.extend(ClassMethods)
			base.send(:include, InstanceMethods)
			base.class_eval do
				unloadable # Send unloadable so it will be reloaded in development
			end
	    end

		module ClassMethods
		end

		module InstanceMethods

			# Método de la configuración principal del plugin redmine_ie.
			def configuration_ie

			end 

		end

	end
end

if Rails::VERSION::MAJOR >= 3
	ActionDispatch::Callbacks.to_prepare do
		AdminController.send(:include, IE::AdminControllerPatch)
	end
else
	Dispatcher.to_prepare do
		AdminController.send(:include, IE::AdminControllerPatch)
	end
end


