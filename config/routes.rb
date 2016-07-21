# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
RedmineApp::Application.routes.draw do
	
	#Rutas para ie_income_expense
	resources :ie_income_expenses

	# Ruta del panel principal de configuración del plugin redmine_ie.
	get '/configuration_ie', :controller => 'admin', :action => 'configuration_ie'

end