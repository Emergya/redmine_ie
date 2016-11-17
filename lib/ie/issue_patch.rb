require_dependency 'issue'

module IE
  module IssuePatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
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
    end
  end
end

ActionDispatch::Callbacks.to_prepare do
  Issue.send(:include, IE::IssuePatch)
end