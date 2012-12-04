module RedmineAttachByUrl
  module IssuePatch
    def self.included(base)
      base.send :include, InstanceMethods
      base.send :unloadable
    end

    module InstanceMethods
      def save_attachments_by_url(attachments)
        if attachments.is_a?(Hash)
          attachments = attachments.values
        end
        if attachments.is_a?(Array)
          attachments.each do |attachment|
            a_by_url = AttachmentByUrl.first(:conditions => [
                'id = ? and state = ?',
                attachment['id'],
                AttachmentByUrl::COMPLETED ])

            if a_by_url && (a = a_by_url.attachment)
              a.filename = attachment['filename'] unless attachment['filename'].blank?
              a.description = attachment['description'].to_s.strip
              saved_attachments << a
            end
          end
        end
        { :files => saved_attachments }
      end
    end
  end
end
