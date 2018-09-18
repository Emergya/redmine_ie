#require 'currency_exchange_rate'

module IE
  module CurrencyExchangeRatePatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        after_save :update_income_expenses, :if => Proc.new{IE::Integration.currency_plugin_enabled?}
        after_destroy :update_income_expenses_selected_year, :if => Proc.new{IE::Integration.currency_plugin_enabled?}
      end
    end

    module InstanceMethods
      def update_income_expenses
        if exchange_changed?
          issues = update_income_expenses_selected_year
          years = CurrencyExchangeRate.where(currency_id: self.currency_id).order(year: "asc")
          year_index = years.index(self)
          if year_index == 0
            Issue.joins("LEFT JOIN custom_values AS cv ON cv.customized_type='Issue' AND cv.customized_id=issues.id AND cv.custom_field_id=#{IE::Integration.currency_field_id} LEFT JOIN custom_field_enumerations AS cfe ON cfe.id = cv.value LEFT JOIN ie_income_expenses AS ie ON ie.tracker_id = issues.tracker_id LEFT JOIN custom_values AS cvd ON ie.planned_end_field_type = 'cf' AND cvd.custom_field_id=ie.planned_end_date_field").
              where("issues.tracker_id IN (?) AND cfe.name = ? AND (CASE WHEN ie.planned_end_field_type = 'attr' THEN YEAR(issues.due_date) WHEN ie.planned_end_field_type = 'cf' THEN YEAR(STR_TO_DATE(cvd.value,'%Y-%m-%d')) END) < ?", IeIncomeExpense.get_trackers, self.currency.name, self.year).
              distinct.
              map(&:update_amount)
          elsif year_index == years.count-1
            Issue.joins("LEFT JOIN custom_values AS cv ON cv.customized_type='Issue' AND cv.customized_id=issues.id AND cv.custom_field_id=#{IE::Integration.currency_field_id} LEFT JOIN custom_field_enumerations AS cfe ON cfe.id = cv.value LEFT JOIN ie_income_expenses AS ie ON ie.tracker_id = issues.tracker_id LEFT JOIN custom_values AS cvd ON ie.planned_end_field_type = 'cf' AND cvd.custom_field_id=ie.planned_end_date_field").
              where("issues.tracker_id IN (?) AND cfe.name = ? AND (CASE WHEN ie.planned_end_field_type = 'attr' THEN YEAR(issues.due_date) WHEN ie.planned_end_field_type = 'cf' THEN YEAR(STR_TO_DATE(cvd.value,'%Y-%m-%d')) END) > ?", IeIncomeExpense.get_trackers, self.currency.name, self.year).
              distinct.
              map(&:update_amount)
          end
          next_year = self.year+1
          until years.find_by(year: next_year).present? or next_year >= years.last.year do
            Issue.joins("LEFT JOIN custom_values AS cv ON cv.customized_type='Issue' AND cv.customized_id=issues.id AND cv.custom_field_id=#{IE::Integration.currency_field_id} LEFT JOIN custom_field_enumerations AS cfe ON cfe.id = cv.value LEFT JOIN ie_income_expenses AS ie ON ie.tracker_id = issues.tracker_id LEFT JOIN custom_values AS cvd ON ie.planned_end_field_type = 'cf' AND cvd.custom_field_id=ie.planned_end_date_field").
              where("issues.tracker_id IN (?) AND cfe.name = ? AND (CASE WHEN ie.planned_end_field_type = 'attr' THEN YEAR(issues.due_date) WHEN ie.planned_end_field_type = 'cf' THEN YEAR(STR_TO_DATE(cvd.value,'%Y-%m-%d')) END) = ?", IeIncomeExpense.get_trackers, self.currency.name, next_year).
              distinct.
              map(&:update_amount)
            next_year += 1
          end
        end
      end
      def update_income_expenses_selected_year
        Issue.joins("LEFT JOIN custom_values AS cv ON cv.customized_type='Issue' AND cv.customized_id=issues.id AND cv.custom_field_id=#{IE::Integration.currency_field_id} LEFT JOIN custom_field_enumerations AS cfe ON cfe.id = cv.value LEFT JOIN ie_income_expenses AS ie ON ie.tracker_id = issues.tracker_id LEFT JOIN custom_values AS cvd ON ie.planned_end_field_type = 'cf' AND cvd.custom_field_id=ie.planned_end_date_field").
          where("issues.tracker_id IN (?) AND cfe.name = ? AND (CASE WHEN ie.planned_end_field_type = 'attr' THEN YEAR(issues.due_date) WHEN ie.planned_end_field_type = 'cf' THEN YEAR(STR_TO_DATE(cvd.value,'%Y-%m-%d')) END) = ?", IeIncomeExpense.get_trackers, self.currency.name, self.year).
          distinct.
          map(&:update_amount)
      end
    end
  end
end

ActionDispatch::Callbacks.to_prepare do
  begin
    CurrencyExchangeRate.send(:include, IE::CurrencyExchangeRatePatch)
  rescue
    false
  end
end