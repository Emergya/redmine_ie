class AddPlannedEndFieldTypeAndPlannedEndDateFieldToIeIncomeExpenses < ActiveRecord::Migration
	def change
    	add_column :ie_income_expenses, :planned_end_field_type, :string
    	add_column :ie_income_expenses, :planned_end_date_field, :string
	end
end