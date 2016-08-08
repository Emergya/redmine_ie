class IeIncomeExpense < ActiveRecord::Base
	belongs_to :tracker
	include Redmine::SubclassFactory

	ALLOWED_ISSUE_FIELDS = [:start_date, :due_date, :created_on, :closed_on, :updated_on]

	# Validaciones
	validates_presence_of :tracker_id, :amount_field_id, :start_date_field, :end_date_field, :type
	validates :tracker_id, :amount_field_id, numericality: { only_integer: true, greater_than: 0, message: l(:"validation.flash_create_error") }
	validate :check_fields_start_and_end_date


	# Returns the Subclasses of IeIncomeExpenses.  Each Subclass needs to be
	# required in development mode. Note: subclasses is protected in ActiveRecord
	def self.get_subclasses
		subclasses
	end

	def self.get_trackers
		distinct("tracker_id").map(&:tracker_id)
	end

	private
		# Se comprueba que la fecha de inicio y de fin es un numero entero y pertenece a un campo personalizado, o se encuentra en ALLOWED_ISSUE_FIELDS.
		def check_fields_start_and_end_date
			errors.add :base, l(:"validation.flash_create_error") if !(/^\d*$/.match(self.start_date_field) || ALLOWED_ISSUE_FIELDS.include?(self.start_date_field.to_sym)) || !(/^\d*$/.match(self.end_date_field) || ALLOWED_ISSUE_FIELDS.include?(self.end_date_field.to_sym))
		end
end

# Force load the subclasses in development mode
require_dependency 'ie_fixed_expense'
require_dependency 'ie_variable_expense'
require_dependency 'ie_variable_income'