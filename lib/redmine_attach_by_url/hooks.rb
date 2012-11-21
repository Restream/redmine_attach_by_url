module AttachByUrl
  class Hooks < Redmine::Hook::Listener
    def controller_issues_edit_before_save(context)
    #   #TODO validate before save

    #   RedmineAttachByUrl::Downloader.validate_url!(url)
    #   RedmineAttachByUrl::Downloader.validate_file_name!(file_name)
    # rescue
    #   raise ActiveRecord::Rollback
    end

    def controller_issues_edit_after_save(context)
      issue_id = context.issue.id
      author_id = User.current.id
      attachments_urls = context.params[:attachments_urls]
      attachments_urls.each do |attachment_url|
        Delayed::Job.enqueue(
          RedmineAttachByUrl::Downloader.new(attachment_url, issue_id, author_id))
      end
    end
  end
end
