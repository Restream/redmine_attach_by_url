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
      download_attachments_by_url(context[:issue],
                                  context[:params][:attachments_by_url])
    end

    def controller_issues_new_after_save(context)
      download_attachments_by_url(context[:issue],
                                  context[:params][:attachments_by_url])
    end

    private

    def download_attachments_by_url(issue, attachment_urls, author = User.current)
      return unless attachment_urls
      attachment_urls.values.each do |attachment_url|
        RedmineAttachByUrl::Downloader.delay.perform(
            attachment_url['url'],
            attachment_url['file_name'],
            attachment_url['description'],
            issue.id, author.id)
      end
    end
  end
end
