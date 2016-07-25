class IeIncomeExpense < ActiveRecord::Base
	unloadable
	belongs_to :tracker
	include Redmine::SubclassFactory

	# Validaciones
	validates_presence_of :tracker_id, :amount_field_id, :start_date_field, :end_date_field, :type

	# Returns the Subclasses of IeIncomeExpenses.  Each Subclass needs to be
	# required in development mode.
	#
	# Note: subclasses is protected in ActiveRecord
	def self.get_subclasses
		subclasses
	end
end

# Force load the subclasses in development mode
require_dependency 'ie_fixed_expense'
require_dependency 'ie_variable_expense'
require_dependency 'ie_variable_income'