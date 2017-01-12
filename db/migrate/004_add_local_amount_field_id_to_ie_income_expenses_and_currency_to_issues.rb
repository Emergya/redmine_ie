class AddLocalAmountFieldIdToIeIncomeExpensesAndCurrencyToIssues < ActiveRecord::Migration
	def change
    	add_column :ie_income_expenses, :local_amount_field_id, :integer, :null => true, :default => nil
    	add_column :issues, :currency, :integer, :null => true, :default => nil
	end
end