require 'ie/tracker_patch'
require 'ie/issue_patch'
require 'ie/integration'
require 'ie/hooks'
require 'ie/currency_patch'
require 'ie/custom_fields_controller_patch'

Redmine::Plugin.register :redmine_ie do
	name 'Income & Expenses'
	author 'Emergya'
	description 'This plugin allows to manage the income and expenses.'
	version '0.0.1'

	requires_redmine :version_or_higher => '3.2'

  	settings :default => {}, :partial => 'settings/ie_settings'

	menu :admin_menu, :"ie.label_income_expenses", { :controller => 'ie_income_expenses', :action => 'index' }, :html => { :class => 'issue_statuses' }, :caption => :"ie.label_income_expenses"
end
