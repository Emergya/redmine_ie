#require 'currency'

module IE
  module CurrencyPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        # safe_attributes 'currency', :if => lambda {|issue, user| issue.new_record? || user.allowed_to?(:edit_issues, issue.project) }
        after_update :update_income_expenses, :if => Proc.new{IE::Integration.currency_plugin_enabled?}

        after_create :add_currency_field_enum, :if =>  Proc.new{IE::Integration.currency_plugin_enabled?}
        after_destroy :destroy_currency_field_enum, :if =>  Proc.new{IE::Integration.currency_plugin_enabled?}
        after_update :update_currency_field_enum, :if =>  Proc.new{IE::Integration.currency_plugin_enabled?}

      end
    end

    module ClassMethods
      def sync_currency_field(custom_field_id)
        begin
          enum = []
          Currency.all.each_with_index do |currency, index|
            enum << CustomFieldEnumeration.new({name: currency.name, active: true, position: index})
          end
          CustomField.find(custom_field_id).enumerations = enum
        rescue
          false
        end
      end
    end

    module InstanceMethods
      def update_income_expenses
        if exchange_changed? or currency_type_changed?
          issues = Issue.joins("LEFT JOIN custom_values AS cv ON cv.customized_type='Issue' AND cv.customized_id=issues.id AND cv.custom_field_id=#{IE::Integration.currency_field_id} LEFT JOIN custom_field_enumerations AS cfe ON cfe.id = cv.value").
            where("issues.tracker_id IN (?) AND cfe.name = ?", IeIncomeExpense.get_trackers, self.name).
            map(&:update_amount)
        end
      end

      def add_currency_field_enum
        CustomField.find(Setting.plugin_redmine_ie['currency_field']).enumerations << CustomFieldEnumeration.new({name: self.name})
      end

      def destroy_currency_field_enum
        CustomField.find(Setting.plugin_redmine_ie['currency_field']).enumerations.where(name: self.name).first.destroy
      end

      def update_currency_field_enum
        CustomField.find(Setting.plugin_redmine_ie['currency_field']).enumerations.where(name: self.name_was).first.update_attribute('name', self.name) if name_changed?
      end
    end
  end
end

ActionDispatch::Callbacks.to_prepare do
  begin
    Currency.send(:include, IE::CurrencyPatch)
  rescue
    false
  end
end