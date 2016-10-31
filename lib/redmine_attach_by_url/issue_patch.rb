require_dependency 'issue'

module RedmineAttachByUrl
  module IssuePatch
    def save_attachments_by_url(attachments)
      attachments = attachments.values if attachments.is_a?(Hash)
      if attachments.is_a?(Array)
        attachments.each do |attachment|
          a_by_url = AttachmentByUrl.find_by(id: attachment['id'].to_i, state: AttachmentByUrl::COMPLETED)

          if a_by_url && (a = a_by_url.attachment)
            a.filename    = attachment['filename'] unless attachment['filename'].blank?
            a.description = attachment['description'].to_s.strip
            saved_attachments << a
          end
        end
      end
      { files: saved_attachments }
    end
  end
end

unless Issue.included_modules.include? RedmineAttachByUrl::IssuePatch
  Issue.send :include, RedmineAttachByUrl::IssuePatch
end
