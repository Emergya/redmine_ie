module IeIncomeExpensesHelper
	# Imprime nombre del tipo de gasto/ingreso
	def get_income_expense_type(type)
		case type
		when  'IeIncomeExpense'
			l("ie.label_income_expenses")
		when  'IeFixedExpense'
			l("ie.label_fixed_expenses")
		when  'IeVariableExpense'
			l("ie.label_variable_expenses")
		when  'IeVariableIncome'
			l("ie.label_variable_income")
		end			
	end

	# Muestra opciones de campo "amount": campos personalizados de  tipo 'int' y 'float'
	def get_fields_type_numeric(tracker)
		custom_fields = tracker.custom_fields.where("field_format = ? OR field_format = ?", 'int', 'float').collect{|custom_field| [custom_field.name, custom_field.id]}
	end

	# Muestra opciones de campos de inicio y fin: campos personalizados del tracker de tipo fecha, campos de Issue de tipo fecha y estados del tracker.
	def get_fields_type_date(tracker, type)
		case type
		when 'attr'
			IeIncomeExpense::ALLOWED_ISSUE_FIELDS.map{|f| [l(:"field_#{f}"), f]}
		when 'cf'
			tracker.custom_fields.where("field_format = ?", 'date').collect{|custom_field| [custom_field.name, custom_field.id]}
		when 'status_id'
			tracker.issue_statuses.map{|s| [s.name, s.id]}
		else
			[]
		end
	end

	# Muestra opciones de tipos de campo de inicio y fin
	def get_fields_type_options
        IeIncomeExpense::ALLOWED_FIELD_TYPES.map{|ft| [l(:"ie.label_#{ft}_plural"), ft]}
	end

	# Muestra opciones de tipos de campo de fin planificado
	def get_planned_fields_type_options
        (IeIncomeExpense::ALLOWED_FIELD_TYPES - [:status_id]).map{|ft| [l(:"ie.label_#{ft}_plural"), ft]}
	end

	# Imprime nombre de campo de inicio
	def income_expense_start_date_field(ie)
		income_expense_date_field(ie.start_field_type, ie.start_date_field)
	end

	# Imprime nombre de campo de fin
	def income_expense_end_date_field(ie)
		income_expense_date_field(ie.end_field_type, ie.end_date_field)
	end

	# Imprime nombre de campo de fin planificado
	def income_expense_planned_end_date_field(ie)
		income_expense_date_field(ie.planned_end_field_type, ie.planned_end_date_field)
	end

	def income_expense_date_field(type, field)
		case type
		when 'attr'
			l("ie.label_attribute_name", :name => field.capitalize)
		when 'cf'
			l("ie.label_custom_field_name", :name => CustomField.find(field).name)
		when 'status_id'
			l("ie.label_status_name", :name => IssueStatus.find(field).name)
		end
	end
end