class IeFixedExpense < IeIncomeExpense
	OptionName = :fixed_expenses

	def issues_scheduled(projects, date)
		get_issues('start', projects, date, true)
	end

	def issues_incurred(projects, date)
		get_issues('end', projects, date, true)
	end

	def issues_scheduled_interval(projects, start_date, end_date)
		issues_scheduled(projects, Date.today).select{|e| e[:due_date] >= start_date}
	end

	def issues_incurred_interval(projects, start_date, end_date)
		issues_scheduled(projects, Date.today).select{|e| e[:start_date] <= end_date and e[:due_date] >= start_date}
	end
end