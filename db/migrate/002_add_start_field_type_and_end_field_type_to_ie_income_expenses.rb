class AddStartFieldTypeAndEndFieldTypeToIeIncomeExpenses < ActiveRecord::Migration
	def change
    	add_column :ie_income_expenses, :start_field_type, :string
    	add_column :ie_income_expenses, :end_field_type, :string
	end
end