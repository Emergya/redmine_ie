require 'ie/tracker_patch'
require 'ie/issue_patch'

Redmine::Plugin.register :redmine_ie do
	name 'Income & Expenses'
	author 'Emergya'
	description 'This plugin allows to manage the income and expenses.'
	version '0.0.1'

	requires_redmine :version_or_higher => '3.2'

	menu :admin_menu, :admin, { :controller => 'ie_income_expenses', :action => 'index' }, :html => { :class => 'issue_statuses' }, :caption => 'Gastos e Ingresos'
end
