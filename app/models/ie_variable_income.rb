class IeVariableIncome < IeIncomeExpense
	OptionName = :variable_income

	def amount_scheduled(projects = Project.all.map(&:id), trackers = IeVariableIncome.get_trackers, start_date = Issue.order(:created_on).first.created_on, end_date = Date.today)
		get_amount(projects, (trackers & IeVariableIncome.get_trackers), start_date, end_date, 'scheduled')
	end

	def amount_incurred(projects = Project.all.map(&:id), trackers = IeVariableIncome.get_trackers, start_date = Issue.order(:created_on).first.created_on, end_date = Date.today)
		get_amount(projects, (trackers & IeVariableIncome.get_trackers), start_date, end_date, 'incurred')
	end
end