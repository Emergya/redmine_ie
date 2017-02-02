class IeIncomeExpensesController < ApplicationController
    layout 'admin'

    skip_before_filter :authorize, :only => [:get_custom_fields, :get_issue_date_field, :update_field_options]
    before_filter :require_admin, :except => [:index, :get_currency_exchange]
    before_filter :find_ie, :only => [:edit, :update, :destroy, :get_custom_fields, :update_field_options]
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
            flash[:error] = @income_expense.errors.full_messages.join('<br>').html_safe
            redirect_to action: 'new', :type => params[:ie_income_expense][:type]
        end
    end

    def edit
       
    end

    def update
        if @income_expense.update_attributes ie_params
          flash[:notice] = l(:"validation.flash_update_notice")
          redirect_to ie_income_expenses_path
        else
          flash[:error] = @income_expense.errors.full_messages.join('<br>').html_safe
          redirect_to action: 'edit', :type => params[:ie_income_expense][:type]
        end
    end

    def destroy
        if @income_expense.destroy
            flash[:notice] = l(:'validation.flash_destroy_notice')
        else
            flash[:error] = @income_expense.errors.full_messages.join('<br>').html_safe
        end

        redirect_to ie_income_expenses_path
    end

    # Método que permite recoger cada uno de los parametros necesarios para el formulario.
    def get_form_data
        # Tipo de gasto/ingreso: 'IeFixedExpense', 'IeVariableExpense', 'IeVariableIncome'
        @type = params[:type]
        # Tracker actualmente seleccionado
        @tracker = (params[:ie_income_expense].present? and params[:ie_income_expense][:tracker_id].present?) ? 
            Tracker.find(params[:ie_income_expense][:tracker_id]) : 
            (@income_expense.present? ? 
                @income_expense.tracker : 
                Tracker.first)
        # Trackers disponibles (excluimos los que ya están siendo usados)
        forbidden_trackers = @income_expense.present? ? IeIncomeExpense.distinct(:tracker_id).where("id <> ?", @income_expense.id) : IeIncomeExpense.distinct(:tracker_id)
        forbidden_trackers = forbidden_trackers.present? ? forbidden_trackers.map(&:tracker_id) : [0]
        @trackers = Tracker.where("id NOT IN (?)", forbidden_trackers).collect{|p| [p.name, p.id]}
        # Tipos de campo para fecha de inicio y fecha de fin: 'attr', 'cf', 'status_id'
        @start_field_type = @income_expense.present? ? @income_expense.start_field_type : 'attr'
        @planned_end_field_type = @income_expense.present? ? @income_expense.planned_end_field_type : 'attr'
        @end_field_type = @income_expense.present? ? @income_expense.end_field_type : 'attr'
    end

    # Método para actualizar contenido del formulario en función del tracker seleccionado
    def get_custom_fields
        @income_expense ||= IeIncomeExpense.new(type: params[:type])
        respond_to do |format|
            format.js
        end
    end

    # Método para actualizar opciones de fecha de inicio o fecha de fin en función del tipo de campo seleccionado
    def update_field_options
        # Indica si se refiere a fecha de inicio ('start') o fecha de fin ('end')
        @type = params[:type]

        # Tipo de campo: 'attr', 'cf' o 'status_id'
        @field_type = (params[:ie_income_expense].present? and params[:ie_income_expense]["#{@type}_field_type".to_sym].present?) ? 
            params[:ie_income_expense]["#{@type}_field_type".to_sym] : 
            'attr'

        # Tracker actualmente seleccionado
        @tracker = (params[:ie_income_expense].present? and params[:ie_income_expense][:tracker_id].present?) ? 
            Tracker.find(params[:ie_income_expense][:tracker_id]) : 
            Tracker.first

        respond_to do |format|
            format.js
        end
    end

    def get_currency_exchange
        exchange = 0
        if params[:currency_enum].present?
            cfe = CustomFieldEnumeration.find(params[:currency_enum])
            if cfe.present?
                currency = IE::Integration.get_currency_by_name(cfe.name)
                exchange = currency.exchange if currency.present?
            end
        end

        render :text => exchange, :layout => false
    end

    private
        def ie_params
            params[:ie_income_expense][:start_date_field] = params[:ie_income_expense][:start_date_field].to_json if params[:ie_income_expense][:start_date_field].is_a?(Array)
            params[:ie_income_expense][:end_date_field] = params[:ie_income_expense][:end_date_field].to_json if params[:ie_income_expense][:end_date_field].is_a?(Array)
            params.require(:ie_income_expense).permit(:tracker_id, :local_amount_field_id, :amount_field_id, :start_date_field, :start_field_type, :planned_end_date_field, :planned_end_field_type, :end_date_field, :end_field_type, :type)
        end

        def find_ie
            @income_expense = IeIncomeExpense.find params[:id] if params[:id].present?
        end
end