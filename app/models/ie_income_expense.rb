class IeIncomeExpense < ActiveRecord::Base
	belongs_to :tracker

	include Redmine::SubclassFactory

	ALLOWED_ISSUE_FIELDS = [:start_date, :due_date, :created_on, :closed_on, :updated_on]
	ALLOWED_FIELD_TYPES = [:attr, :cf, :status_id]

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

	def get_amount(projects, trackers, start_date, end_date, type_amount)
		total_amount = 0
				
		Issue.where("project_id IN (?) AND tracker_id IN (?)", projects, trackers).group_by(&:tracker_id).each do |tracker_id, issues|
			# Recoger los valores amount, start_date y end_date especificos para el tracker de esa petición.
			ie_income_expense = IeFixedExpense.where(tracker_id: tracker_id).first

			if ie_income_expense.present? # Comprobamos que haya una configuración para ese tracker.
				issues.each do |issue|

					issue_amount     = issue.custom_values.where("customized_type = 'Issue' AND custom_field_id = ?", ie_income_expense.amount_field_id).first.value.to_i

					issue_start_date = ie_income_expense.start_date_field.is_a?(Numeric) ?
									        issue.custom_values.where("customized_type = 'Issue' AND custom_field_id = ?", ie_income_expense.start_date_field).first.value :
									        issue[ie_income_expense.start_date_field.to_sym]

					issue_end_date   = ie_income_expense.end_date_field.is_a?(Numeric) ?
									        issue.custom_values.where("customized_type = 'Issue' AND custom_field_id = ?", ie_income_expense.end_date_field).first.value :
									        issue[ie_income_expense.end_date_field.to_sym]

					# Condición: issue_start_date de la petición este dentro del rango del periodo indicado o issue_start_date sea menor que el periodo y issue_end_date se encuentre dentro del periodo o superior al mismo.
					case type_amount
						when 'scheduled'
							total_amount += issue_amount if scheduled_condition(start_date, end_date, issue_start_date, issue_end_date)
						when 'incurred'
							total_amount += issue_amount if incurred_condition(start_date, end_date, issue_start_date, issue_end_date)
					end
				end
			end
		end

		return total_amount
	end

	def scheduled_condition(start_date, end_date, issue_start_date, issue_end_date)
		issue_start_date.between?(start_date, end_date) || (issue_start_date.to_date < start_date && (issue_end_date.between?(start_date, end_date) || issue_end_date.to_date > end_date))
	end

	def incurred_condition(start_date, end_date, issue_start_date, issue_end_date)
		issue_end_date.between?(start_date, end_date)
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