module IeIncomeExpensesHelper

	# Campos personalizados de  tipo 'int' y 'float'
	def get_fields_type_numeric(tracker)
		custom_fields = tracker.custom_fields.where("field_format = ? OR field_format = ?", 'int', 'float').collect{|custom_field| [custom_field.name, custom_field.id]}
	end

	# Campos personalizado de tipo 'date' y los campos de Issue de tipo fecha.
	def get_fields_type_date(tracker)
		custom_fields = tracker.custom_fields.where("field_format = ?", 'date').collect{|custom_field| [custom_field.name, custom_field.id]}
		issue_date_fields = IeIncomeExpense::ALLOWED_ISSUE_FIELDS.map{|f| [l(:"field_#{f}"), f]}

		custom_fields + issue_date_fields
	end

end