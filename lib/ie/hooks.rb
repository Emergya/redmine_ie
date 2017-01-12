module IE
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issues_form_details_top,
              :partial => 'hooks/view_issues_form_details_top'
  end
end