class IeFixedExpense < IeIncomeExpense
	OptionName = :fixed_expenses

	# --------------------------------------------------
	#               DUDAS y PUNTOS PARA VER
	# --------------------------------------------------
	# 1. ¿Habría que controlar en el caso de que un mismo tracker este configurado para una misma subclase? En el caso de que se pudiera dar esa condición.
	# 2. Excluir los trackers cuando la variable tracker viene definida -> trackers.select{|t| IeFixedExpense.get_trackers.include?(t)} 
	#    ¿Sería viable (como ya se encuentra) usando project.issues.where("tracker_id IN (?)", trackers)? De esta forma no habria que excluir ningun tracker.
	# 3. El lógica del cálculo de la cantidad prevista e incurrida es practicamente la misma, ¿seria viable reducirlo todo a un método
	#    e indicarle mediante parámetro si el cálculo sería para el total previsto o incurrido? Dejo al final del todo (código comentado) como quedaria por si fuera viable.
	#    De esta forma se podria eliminar los metodos de amount_scheduled y amount_incurred.
	#
	# Notas:
	#      º Previsto:
	#            - issue_start_date se encuentre en periodo.
	#            - issue_start_date sea anterior al periodo y issue_end_date este dentro del periodo o sea superior al periodo.
	#      º Incurrido:
	#            - issue_end_date se encuentre en el periodo.

	def amount_scheduled(projects = Project.all.map(&:id), trackers = IeFixedExpense.get_trackers, start_date = Issue.order(:created_on).first.created_on, end_date = Date.today)
		
		total_amount = 0
		projects.each do |project_id| # Recorrer los proyectos.
			project = Project.find project_id
			project.issues.where("tracker_id IN (?)", trackers).each do |issue| # Recorrer las peticiones de cada proyecto.

				# Recoger los valores amount, start_date y end_date especificos para el tracker de esa petición.
				ie_fixed_expense = IeFixedExpense.where(tracker_id: issue.tracker_id).first

				if IeFixedExpense.all.count > 0 && ie_fixed_expense.present? # Comprobamos que haya una configuración para ese tracker.

					issue_amount     = issue.custom_values.where("customized_type = 'Issue' AND custom_field_id = ?", ie_fixed_expense.amount_field_id).first.value.to_i

					issue_start_date = ie_fixed_expense.start_date_field.is_a?(Numeric) ?
									        issue.custom_values.where("customized_type = 'Issue' AND custom_field_id = ?", ie_fixed_expense.start_date_field).first.value :
									        issue[ie_fixed_expense.start_date_field.to_sym]

					issue_end_date   = ie_fixed_expense.end_date_field.is_a?(Numeric) ?
									        issue.custom_values.where("customized_type = 'Issue' AND custom_field_id = ?", ie_fixed_expense.end_date_field).first.value :
									        issue[ie_fixed_expense.end_date_field.to_sym]

					# Condición: issue_start_date de la petición este dentro del rango del periodo indicado o issue_start_date sea menor que el periodo y issue_end_date se encuentre dentro del periodo o superior al mismo.
					if issue_start_date.between?(start_date, end_date) || (issue_start_date.to_date < start_date && (issue_end_date.between?(start_date, end_date) || issue_end_date.to_date > end_date))
						total_amount += issue_amount 
					end

				end
			end
		end

		return total_amount

	end

	def amount_incurred(projects = Project.all.map(&:id), trackers = IeFixedExpense.get_trackers, start_date = Issue.order(:created_on).first.created_on, end_date = Date.today)

		total_amount = 0
		projects.each do |project_id| # Recorrer los proyectos.
			project = Project.find project_id
			project.issues.where("tracker_id IN (?)", trackers).each do |issue| # Recorrer las peticiones de cada proyecto.

				# Recoger los valores amount, start_date y end_date especificos para el tracker de esa petición.
				ie_fixed_expense = IeFixedExpense.where(tracker_id: issue.tracker_id).first

				if IeFixedExpense.all.count > 0 && ie_fixed_expense.present? # Comprobamos que haya una configuración para ese tracker.

					issue_amount     = issue.custom_values.where("customized_type = 'Issue' AND custom_field_id = ?", ie_fixed_expense.amount_field_id).first.value.to_i

					issue_start_date = ie_fixed_expense.start_date_field.is_a?(Numeric) ?
									        issue.custom_values.where("customized_type = 'Issue' AND custom_field_id = ?", ie_fixed_expense.start_date_field).first.value :
									        issue[ie_fixed_expense.start_date_field.to_sym]

					issue_end_date   = ie_fixed_expense.end_date_field.is_a?(Numeric) ?
									        issue.custom_values.where("customized_type = 'Issue' AND custom_field_id = ?", ie_fixed_expense.end_date_field).first.value :
									        issue[ie_fixed_expense.end_date_field.to_sym]

					# Condición: issue_end_date de la petición debe de encontrarse dentro del periodo
					if issue_end_date.between?(start_date, end_date)
						total_amount += issue_amount 
					end

				end
			end
		end

		return total_amount

	end

	# def calculate_amount(projects = Project.all.map(&:id), trackers = IeFixedExpense.get_trackers, start_date = Issue.order(:created_on).first.created_on, end_date = Date.today, type_amount)

	# 	total_amount = 0
	# 	projects.each do |project_id| # Recorrer los proyectos.
	# 		project = Project.find project_id
	# 		project.issues.where("tracker_id IN (?)", trackers).each do |issue| # Recorrer las peticiones de cada proyecto.

	# 			# Recoger los valores amount, start_date y end_date especificos para el tracker de esa petición.
	# 			ie_fixed_expense = IeFixedExpense.where(tracker_id: issue.tracker_id).first

	# 			if IeFixedExpense.all.count > 0 && ie_fixed_expense.present? # Comprobamos que haya una configuración para ese tracker.

	# 				issue_amount     = issue.custom_values.where("customized_type = 'Issue' AND custom_field_id = ?", ie_fixed_expense.amount_field_id).first.value.to_i

	# 				issue_start_date = ie_fixed_expense.start_date_field.is_a?(Numeric) ?
	# 								        issue.custom_values.where("customized_type = 'Issue' AND custom_field_id = ?", ie_fixed_expense.start_date_field).first.value :
	# 								        issue[ie_fixed_expense.start_date_field.to_sym]

	# 				issue_end_date   = ie_fixed_expense.end_date_field.is_a?(Numeric) ?
	# 								        issue.custom_values.where("customized_type = 'Issue' AND custom_field_id = ?", ie_fixed_expense.end_date_field).first.value :
	# 								        issue[ie_fixed_expense.end_date_field.to_sym]


	# 				case type_amount
	# 					when "scheduled"
	# 						if issue_start_date.between?(start_date, end_date) || (issue_start_date.to_date < start_date && (issue_end_date.between?(start_date, end_date) || issue_end_date.to_date > end_date))
	# 							total_amount += issue_amount 
	# 						end
	# 					when "incurred"
	# 						if issue_end_date.between?(start_date, end_date)
	# 							total_amount += issue_amount 
	# 						end
	# 				end

	# 			end
	# 		end
	# 	end

	# 	return total_amount

	# end
end