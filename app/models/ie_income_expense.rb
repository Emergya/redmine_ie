class IeIncomeExpense < ActiveRecord::Base
	belongs_to :tracker
	has_many :issues, :through => :tracker

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

	def issues_scheduled(projects, date)
		get_issues('start', projects, date)
	end

	def issues_incurred(projects, date)
		get_issues('end', projects, date)
	end

	def issues_scheduled_interval(projects, start_date, end_date)
		get_issues_interval('start', projects, start_date, end_date)
	end

	def issues_incurred_interval(projects, start_date, end_date)
		get_issues_interval('end', projects, start_date, end_date)
	end

	private
		# Se comprueba que la fecha de inicio y de fin es un numero entero y pertenece a un campo personalizado, o se encuentra en ALLOWED_ISSUE_FIELDS.
		def check_fields_start_and_end_date
			errors.add :base, l(:"validation.flash_create_error") if !(/^\d*$/.match(self.start_date_field) || ALLOWED_ISSUE_FIELDS.include?(self.start_date_field.to_sym)) || !(/^\d*$/.match(self.end_date_field) || ALLOWED_ISSUE_FIELDS.include?(self.end_date_field.to_sym))
		end

		def get_issues(start_end, projects, date)
			type = self["#{start_end}_field_type"]
			field = self["#{start_end}_date_field"]

			# Join para el importe actual
			join_current_amount = "LEFT JOIN custom_values AS current_amount ON current_amount.customized_type = 'Issue' AND current_amount.customized_id = issues.id AND current_amount.custom_field_id = #{amount_field_id}"
			# Join para el valor de la fecha cuando el tipo es 'cf'
			join_cf_current = "LEFT JOIN custom_values ON custom_values.customized_type = 'Issue' AND custom_values.customized_id = issues.id AND custom_values.custom_field_id = #{field}"
			# Condición para que se cumpla que la petición es estimada/incurrida cuando el tipo es 'status_id'
			where_status_current = "issues.status_id = #{field}"
			# Condición para que se cumpla que la petición es estimada/incurrida cuando el tipo es 'attr'
			where_attr_current = "DATE(issues.#{field}) <= '#{date}'"
			# Condición para que se cumpla que la petición es estimada/incurrida cuando el tipo es 'cf'
			where_cf_current = "DATE(custom_values.value) <= '#{date}'"

			if date >= Date.today
				case type
				when 'status_id'
					join_current_value = ""
					condition_current = where_status_current
				when 'attr'
					join_current_value = ""
					condition_current = where_attr_current
				when 'cf'
					join_current_value = join_cf_current
					condition_current = where_cf_current
				else
					return []
				end

				result = issues.
					joins(join_current_amount+" "+join_current_value).
					where("issues.project_id IN (#{projects.join(',')}) AND "+condition_current).
					select("issues.*, current_amount.value AS amount").to_a
			else
			# Si la fecha de medición es anterior a la actual, hay que tener en cuenta el histórico de cambios en las peticiones	
				case type
				when 'status_id'
					property = 'attr'
					prop_key = 'status_id'
					# Condition for scheduled/incurred when there is a change on status value after "date"
					condition_next_change = "next_change.old_value = #{field}"
					# Condition for scheduled/incurred when there are no changes on status value after "date"
					join_current_value = ""
					condition_current = where_status_current
				when 'attr'
					property = 'attr'
					prop_key = field
					# Condition for scheduled/incurred when there is a change on related attribute value after "date"
					condition_next_change = "DATE(next_change.old_value) <= '#{field}'"
					# Condition for scheduled/incurred when there are no changes on related attribute value after "date"
					join_current_value = ""
					condition_current = where_attr_current
				when 'cf'
					property = 'cf'
					prop_key = field
					# Condition for scheduled/incurred when there is a change on custom field value after "date"
					condition_next_change = "DATE(next_change.old_value) <= '#{field}'"
					# Condition for scheduled/incurred when there are no changes on custom field value after "date"
					join_current_value = join_cf_current
					condition_current = where_cf_current
				else
					return []
				end


				# Get the id for the next journal that changes the related attribute/custom field/state
				query_next_change = "SELECT jd.id FROM journal_details AS jd LEFT JOIN journals AS j ON jd.journal_id = j.id WHERE j.journalized_type = 'Issue' AND j.journalized_id = issues.id AND DATE(j.created_on) > '#{date}' AND jd.property = '#{property}' AND jd.prop_key = '#{prop_key}' LIMIT 1"
				# Get the id for the next journal that changes the custom_field value for amount
				query_next_amount = "SELECT jd.id FROM journal_details AS jd LEFT JOIN journals AS j ON jd.journal_id = j.id WHERE j.journalized_type = 'Issue' AND j.journalized_id = issues.id AND DATE(j.created_on) > '#{date}' AND jd.property = 'cf' AND jd.prop_key = '#{amount_field_id}' LIMIT 1"

				# Get issues that were created after "date" and meet with one of these conditions:
				# * The "old_value" field in the next journal change makes that issue as scheduled/incurred (condition_next_change)
				# * There isn't next journal change and the issue is currently scheduled/incurred (condition_current)
				# For each issue selected, get amount as one of these:
				# * If there are any change on the amount custom field after "date", get the "old_value" field from that journal
				# * If there are no journal changes on the amount custom field after "date", get the current value of that field
				result = issues.joins("LEFT JOIN journal_details AS next_change ON next_change.id = (#{query_next_change}) LEFT JOIN journal_details AS next_amount ON next_amount.id = (#{query_next_amount}) #{join_current_amount} #{join_current_value}").
					where("issues.project_id IN (#{projects.join(',')}) AND DATE(issues.created_on) <= '#{date}' AND (#{condition_next_change} OR (next_change.id IS NULL AND #{condition_current}))").
					select("issues.*, IF(next_amount.id IS NULL, current_amount.value, next_amount.old_value) AS amount").to_a

			end
		end

		# Solo para el punto de vista actual
		def get_issues_interval(start_end, projects, start_date, end_date)
			type = self["#{start_end}_field_type"]
			field = self["#{start_end}_date_field"]

			if planned_end_field_type == 'cf'
				# Join para la fecha de fin estimada (cuando es de tipo 'cf')
				join_planned_end_date = "LEFT JOIN custom_values As planned_end_date ON planned_end_date.customized_type = 'Issue' AND planned_end_date.customized_id = issues.id AND planned_end_date.custom_field_id = #{planned_end_date_field}"
				# Condición para la fecha de fin estimada (cuando es de tipo 'cf')
				condition_planned_end_date = "DATE(planned_end_date.value) BETWEEN '#{start_date}' AND '#{end_date}'"
			else
				# Join VACIO para la fecha de fin estimada (cuando es de tipo 'attr')
				join_planned_end_date = ""
				# Condición para la fecha de fin estimada (cuando es de tipo 'attr')
				condition_planned_end_date = "DATE(issues.#{planned_end_date_field}) BETWEEN '#{start_date}' AND '#{end_date}'"
			end
			# Join para el importe actual
			join_amount = "LEFT JOIN custom_values AS current_amount ON current_amount.customized_type = 'Issue' AND current_amount.customized_id = issues.id AND current_amount.custom_field_id = #{amount_field_id}"
			# Join para el valor de la fecha cuando el tipo es 'cf'
			join_cf = "LEFT JOIN custom_values ON custom_values.customized_type = 'Issue' AND custom_values.customized_id = issues.id AND custom_values.custom_field_id = #{field}"
	

			case type
			when 'status_id'
				join_value = ""
				condition = "issues.status_id = #{field}"
			when 'attr'
				join_value = ""
				condition = "DATE(issues.#{field}) <= '#{end_date}'"
			when 'cf'
				join_value = join_cf
				condition = "DATE(custom_values.value) <= '#{end_date}'"
			else
				return []
			end

			result = issues.
				joins(join_amount+" "+join_planned_end_date+" "+join_value).
				where("issues.project_id IN (#{projects.join(',')}) AND "+condition_planned_end_date+" AND "+condition).
				select("issues.*, current_amount.value AS amount").to_a
		end
end

# Force load the subclasses in development mode
require_dependency 'ie_fixed_expense'
require_dependency 'ie_variable_expense'
require_dependency 'ie_variable_income'