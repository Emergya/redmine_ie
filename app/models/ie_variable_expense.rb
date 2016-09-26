class IeVariableExpense < IeIncomeExpense
	OptionName = :variable_expenses

	def amount_scheduled(projects = Project.all.map(&:id), trackers = IeVariableExpense.get_trackers, start_date = Issue.order(:created_on).first.created_on, end_date = Date.today)
		get_amount(projects, (trackers & IeVariableExpense.get_trackers), start_date, end_date, 'scheduled')
	end

	def amount_incurred(projects = Project.all.map(&:id), trackers = IeVariableExpense.get_trackers, start_date = Issue.order(:created_on).first.created_on, end_date = Date.today)
		get_amount(projects, (trackers & IeVariableExpense.get_trackers), start_date, end_date, 'incurred')
	end
end