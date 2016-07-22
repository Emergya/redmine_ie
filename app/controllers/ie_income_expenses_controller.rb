class IeIncomeExpensesController < ApplicationController
    unloadable

    skip_before_filter :authorize, :only => [:get_custom_fields, :get_issue_date_field]

    def new
        @income_expense = IeIncomeExpense.new
        @trackers = Tracker.all.collect{|p| [p.name, p.id]}
    end

    #  Método para recoger los campos personalizados que pertenecen a un determinado tracker.
    def get_custom_fields
        tracker = Tracker.find(params[:tracker_id])
        custom_fields = tracker.custom_fields.collect{|custom_field| [custom_field.name, custom_field.id]}

        respond_to do |format|
            format.json { render json: {:custom_fields => custom_fields} }
        end
    end

    # Método para recoger los campos del modelo Issue de tipo fecha.
    def get_issue_date_fields
        issue_date_fields = Hash.new
        issue_date_fields[:start_date] = l(:field_start_date)  # Fecha de inicio         
        issue_date_fields[:due_date]   = l(:field_due_date)    # Fecha de fin            
        issue_date_fields[:created_on] = l(:field_created_on)  # Fecha de creación       
        issue_date_fields[:closed_on]  = l(:field_closed_on)   # Fecha de cierre         
        issue_date_fields[:updated_on] = l(:field_updated_on)  # Fecha de actualización  

        respond_to do |format|
            format.json { render json: {:issue_date_fields => issue_date_fields} }
        end
    end
end