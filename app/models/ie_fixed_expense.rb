class IeFixedExpense < IeIncomeExpense
	OptionName = :fixed_expenses

	# Notas:
	#      º Previsto:
	#            - issue_start_date se encuentre en periodo.
	#            - issue_start_date sea anterior al periodo y issue_end_date este dentro del periodo o sea superior al periodo.
	#      º Incurrido:
	#            - issue_end_date se encuentre en el periodo.

	def amount_scheduled(projects = Project.all.map(&:id), trackers = IeFixedExpense.get_trackers, start_date = Issue.order(:created_on).first.created_on, end_date = Date.today)
		get_amount(projects, (trackers & IeFixedExpense.get_trackers), start_date, end_date, 'scheduled')
	end

	def amount_incurred(projects = Project.all.map(&:id), trackers = IeFixedExpense.get_trackers, start_date = Issue.order(:created_on).first.created_on, end_date = Date.today)
		get_amount(projects, (trackers & IeFixedExpense.get_trackers), start_date, end_date, 'incurred')
	end

end