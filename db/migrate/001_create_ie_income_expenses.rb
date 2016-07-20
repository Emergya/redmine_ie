class CreateIeIncomeExpenses < ActiveRecord::Migration
	def change

		create_table :ie_income_expenses, :force => true do |t|
			t.column :tracker_id, :integer
			t.column :amount_field_id, :integer
			t.column :start_date_field, :string
			t.column :end_date_field, :string
			t.column :type, :string
		end

	end
end