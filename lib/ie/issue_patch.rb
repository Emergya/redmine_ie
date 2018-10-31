require_dependency 'issue'

module IE
  module IssuePatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        has_one :ie_income_expense, :through => :tracker

        # validate :validate_has_planned_end_field
        after_save :update_amount
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def historic_value(date)
        if date >= Date.today
          actual_value
        else
          changes = journals.joins(:details).where("journals.created_on >= ? AND journal_details.property IN ('attr', 'cf')", date).select("journals.created_on, IF(journal_details.property='attr', journal_details.prop_key, CONCAT('cf_',journal_details.prop_key)) AS name, journal_details.old_value AS value")
          changes = changes.group_by{|x| x['name']}.map{|k, v| [k, v.min_by{|x| x['created_on']}[:value]]}.to_h
          actual_value.merge(changes)
        end
      end

      def actual_value
        attributes.merge(custom_values.map{|x| {"cf_"+x[:custom_field_id].to_s => x[:value]}}.reduce(&:merge))
      end

      def update_amount
        if currency.present? and ie_income_expense.present? and ie_income_expense.local_amount_field_id.present? and ie_income_expense.amount_field_id.present?
          # if ((currency.currency_type == 'dinamic') or (currency.currency_type == 'static' and !billed?))
            if ie_income_expense.planned_end_field_type == 'attr'
              planned_end_year = self.read_attribute(ie_income_expense.planned_end_date_field).year
            elsif ie_income_expense.planned_end_field_type == 'cf'
              planned_end_year = Date.parse(custom_values.find_by_custom_field_id(ie_income_expense.planned_end_date_field).value).year
            end

            local_amount = custom_values.find_by_custom_field_id(ie_income_expense.local_amount_field_id)
            amount = custom_values.find_by_custom_field_id(ie_income_expense.amount_field_id)
            if amount.present? and local_amount.present?
              cer = currency.currency_exchange_rate.find_by(year: planned_end_year)
              if cer.present?
                exchange_rate = cer.exchange.to_f
              else
                begin
                  previous_years_currency_exchange_rates = currency.currency_exchange_rate.where("year < ?", planned_end_year).order(year: "desc");
                  if previous_years_currency_exchange_rates.present?
                    exchange_rate = previous_years_currency_exchange_rates.first.exchange.to_f
                  else
                    exchange_rate = currency.currency_exchange_rate.where("year > ?", planned_end_year).order(year: "asc").first.exchange.to_f
                  end
                rescue
                  exchange_rate = Float::MAX
                end
              end
              amount.value = local_amount.value.to_f / exchange_rate
              # amount.value = local_amount.value.to_f / currency.exchange.to_f
              amount.save
            end
          # end
        end
      end

      def billed?
        begin
          if ie_income_expense.present?
            case ie_income_expense.end_field_type
            when 'status_id'
              return JSON.parse(ie_income_expense.end_date_field).include?(status_id.to_s)
            when 'attr'
              return self[ie_income_expense.end_date_field] <= Date.today
            when 'cf'
              return Date.parse(custom_values.find_by_custom_field_id(ie_income_expense.end_date_field).value) <= Date.today
            end
          end
          false
        rescue
          false
        end
      end

      # def validate_has_planned_end_field
      #   if currency.present? and ie_income_expense.present? and ie_income_expense.local_amount_field_id.present? and ie_income_expense.amount_field_id.present?
      #     if ie_income_expense.planned_end_field_type == 'attr'
      #       fecha = self.read_attribute(ie_income_expense.planned_end_date_field)
      #     elsif ie_income_expense.planned_end_field_type == 'cf'
      #       fecha = custom_values.find_by_custom_field_id(ie_income_expense.planned_end_date_field)
      #     else
      #       return
      #     end
      #     errors.add(:base, l(:"validation.end_planned_date_not_found")) if fecha.blank?
      #   end
      # end

      private
      def currency
        begin
          #if IE::Integration.currency_plugin_enabled?
            currency_field = custom_values.find_by_custom_field_id(IE::Integration.currency_field_id)
            IE::Integration.get_currency_by_name(CustomFieldEnumeration.find(currency_field.value).name)
          #else
          #  nil
          #end
        rescue
          nil
        end
      end
    end
  end
end

ActionDispatch::Callbacks.to_prepare do
  Issue.send(:include, IE::IssuePatch)
end