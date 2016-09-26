class IeIncomeExpensesController < ApplicationController
    layout 'admin'

    skip_before_filter :authorize, :only => [:get_custom_fields, :get_issue_date_field]
    before_filter :require_admin, :except => :index
    before_filter :find_ie, :only => [:edit, :update, :destroy, :get_custom_fields]
    before_filter :get_form_data, :only => [:new, :edit, :get_custom_fields]

    def index

    end

    def new
        @income_expense = IeIncomeExpense.new(type: params[:type])
    end

    def create
        ie_income_expense = IeIncomeExpense.new ie_params

        if ie_income_expense.save
            flash[:notice] = l(:"validation.flash_create_notice")
            redirect_to ie_income_expenses_path
        else
            binding.pry
            flash[:error] = l(:"validation.flash_create_error")
            redirect_to action: 'new', :type_name => params[:ie_income_expense][:type_name], :type => params[:ie_income_expense][:type]
        end
    end

    def edit
       
    end

    def update
        if @income_expense.update_attributes ie_params
          flash[:notice] = l(:"validation.flash_update_notice")
          redirect_to ie_income_expenses_path
        else
          flash[:error] = l(:"validation.flash_update_error")
          redirect_to action: 'edit', :type_name => params[:ie_income_expense][:type_name], :type => params[:ie_income_expense][:type]
        end
    end

    def destroy
        if @income_expense.destroy
            flash[:notice] = l(:'validation.flash_destroy_notice')
        else
            flash[:error] = l(:'validation.flash_destroy_error')
        end

        redirect_to ie_income_expenses_path
    end

    # Método que permite recoger cada uno de los parametros necesarios para el formulario.
    def get_form_data
        @type = params[:type]
        @type_name = params[:type_name]
        @tracker = (params[:ie_income_expense].present? and params[:ie_income_expense][:tracker_id].present?) ? 
            Tracker.find(params[:ie_income_expense][:tracker_id]) : 
            (@income_expense.present? ? 
                @income_expense.tracker : 
                Tracker.first)
        @trackers = Tracker.all.reject{|x| IeIncomeExpense.where("tracker_id = ?", x.id).present?}.collect{|p| [p.name, p.id]}
    end

    #  Método para recoger los campos personalizados que pertenecen a un determinado tracker.
    def get_custom_fields
        @income_expense ||= IeIncomeExpense.new(type: params[:type])
        respond_to do |format|
            format.js
        end
    end

    private
        def ie_params
            params.require(:ie_income_expense).permit(:tracker_id, :amount_field_id, :start_date_field, :end_date_field, :type)
        end

        def find_ie
            @income_expense = IeIncomeExpense.find params[:id] if params[:id].present?
        end
end