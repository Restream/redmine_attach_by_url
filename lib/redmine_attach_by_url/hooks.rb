module RedmineAttachByUrl
  class Hooks < Redmine::Hook::Listener
    def controller_issues_edit_before_save(context)
      issue  = context[:issue]
      params = context[:params]
      issue.save_attachments_by_url(params[:attachments_by_url])
    end

    def controller_issues_new_before_save(context)
      issue  = context[:issue]
      params = context[:params]
      issue.save_attachments_by_url(params[:attachments_by_url])
    end
  end
end
