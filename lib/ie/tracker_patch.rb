require_dependency 'tracker'
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

module IE
	module TrackerPatch
		def self.included(base) # :nodoc:
			base.extend(ClassMethods)
			base.send(:include, InstanceMethods)

			base.class_eval do
				has_many :ie_income_expenses, :dependent => :destroy
			end
		end

		module ClassMethods
		end

		module InstanceMethods
		end
	end
end

if Rails::VERSION::MAJOR >= 3
	ActionDispatch::Callbacks.to_prepare do
		Tracker.send(:include, IE::TrackerPatch)
	end
else
	Dispatcher.to_prepare do
		Tracker.send(:include, IE::TrackerPatch)
	end
end