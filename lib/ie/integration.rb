module IE
	class Integration
		class << self
			def currency_plugin_enabled?
				(Setting.plugin_redmine_ie["plugin_currency"].present? and Setting.plugin_redmine_ie['currency_field'].present?)
			end

		  	# Currency plugin
		  	def get_default_currency
		  		self.currency_plugin_enabled? ? Currency.default_currency : nil
		  	end

		  	def get_currencies
		  		self.currency_plugin_enabled? ? Currency.all : []
		  	end

		  	def get_currency(currency)
		  		self.currency_plugin_enabled? ? Currency.find(currency) : nil
		  	end

		  	def get_currency_by_name(currency_name)
		  		self.currency_plugin_enabled? ? Currency.find_by(name: currency_name) : nil
		  	end

		  	def currency_field_id
		  		self.currency_plugin_enabled? ? Setting.plugin_redmine_ie['currency_field'] : nil
		  	end

		  	def get_prefered_currency
		  		begin
		  			self.currency_plugin_enabled? ? Currency.default_currency : nil
		  		rescue
		  			nil
		  		end
		  	end
		end
	end
end