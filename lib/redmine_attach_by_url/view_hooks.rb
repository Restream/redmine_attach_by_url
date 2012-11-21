module AttachByUrl
  class ViewHooks < Redmine::Hook::ViewListener
    render_on :view_issues_form_details_bottom,
              :partial => 'redmine_attach_by_url/add_attachment_by_url'
  end
end
