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
      issue = context[:issue]
      author = User.current
      attachments_urls = context[:params][:attachments_by_url]
      attachments_urls.values.each do |attachment_url|
        Delayed::Job.enqueue(
          RedmineAttachByUrl::Downloader.new(
              attachment_url['url'],
              attachment_url['file_name'],
              attachment_url['description'],
              issue.id, author.id)
        )
      end
    end
  end
end
