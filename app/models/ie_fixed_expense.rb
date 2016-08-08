class IeFixedExpense < IeIncomeExpense
	OptionName = :fixed_expenses

	def amount_scheduled(projects = Project.all.map(&:id), trackers = IeFixedExpense.get_trackers, start_date = Issue.order(:created_on).first.created_on, end_date = Date.today)
		trackers.select{|t| IeFixedExpense.get_trackers.include?(t)} # excluir los trackers cuando la variable tracker viene definida
	end

	def amount_incurred
	end
end