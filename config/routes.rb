# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
RedmineApp::Application.routes.draw do

	#Rutas para ie_income_expense
	resources :ie_income_expenses

	# Ruta para recoger los campos personalizados de un tracker específico.
	get '/get_custom_fields', :controller => 'ie_income_expenses', :action => 'get_custom_fields'
	get '/update_field_options', :controller => 'ie_income_expenses', :action => 'update_field_options'

	# Ruta para recoger el factor de conversión de una moneda
	get '/get_currency_exchange', :controller => 'ie_income_expenses', :action => 'get_currency_exchange'

	# Ruta para sincronizar un campo personalizado con el listado de divisas
	match '/sync_currency_field' => 'custom_fields#sync_currency_field', :via => [:get, :post]
end