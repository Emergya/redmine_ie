# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
RedmineApp::Application.routes.draw do

	#Rutas para ie_income_expense
	resources :ie_income_expenses

	# Ruta del panel principal de configuración del plugin redmine_ie.
	get '/configuration_ie', :controller => 'admin', :action => 'configuration_ie'

	# Ruta para recoger los campos personalizados de un tracker específico.
	get '/get_custom_fields', :controller => 'ie_income_expenses', :action => 'get_custom_fields'

	# Ruta para recoger los campos del modelo Issue de tipo Fecha.
	get '/get_issue_date_fields', :controller => 'ie_income_expenses', :action => 'get_issue_date_fields'
	
end