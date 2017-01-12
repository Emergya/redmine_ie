module IE
	module CustomFieldsControllerPatch
		def self.included(base) # :nodoc:
			base.extend(ClassMethods)
			base.send(:include, InstanceMethods)

			base.class_eval do
			end
		end

		module ClassMethods
		end

		module InstanceMethods
			def sync_currency_field
			  if IE::Integration.currency_plugin_enabled? and params[:custom_field].present? 
			  	if Currency.sync_currency_field(params[:custom_field])
				    render :text => 'success'
				  else
				    render :text => 'error'
				  end
				end
			end
		end
	end
end

ActionDispatch::Callbacks.to_prepare do
	CustomFieldsController.send(:include, IE::CustomFieldsControllerPatch)
end
