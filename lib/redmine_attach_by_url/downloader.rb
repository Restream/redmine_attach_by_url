require 'open-uri'

module RedmineAttachByUrl
  module OriginalFilename
    attr_accessor :original_filename
  end

  class Downloader
    attr_reader :attach

    # update state every X seconds
    UPDATE_INTERVAL = 1

    def initialize(attachment_by_url_id)
      @attach = AttachmentByUrl.find(attachment_by_url_id)
    end

    def download
      return unless attach && attach.state == AttachmentByUrl::QUEUED
      attach.state = AttachmentByUrl::IN_PROGRESS
      attach.save!
      uri = URI.parse(attach.url)
      file = uri.open(
        :content_length_proc => lambda { |total|
          attach.total_bytes = total
        },
        :progress_proc => lambda { |downloaded_bytes|
          attach.complete_bytes = downloaded_bytes
          attach.save! if Time.now - attach.updated_at > UPDATE_INTERVAL
        }
      )
      file.extend OriginalFilename
      file.original_filename = guess_file_name(file.content_type)
      a = Attachment.create(:file => file, :author => attach.author)
      if (a.new_record?)
        attach.state = AttachmentByUrl::FAILED
        attach.state_text = a.errors.full_messages.join("; ")
      else
        attach.state = AttachmentByUrl::COMPLETED
      end

      attach.save! if attach.changed?
    rescue OpenURI::HTTPError => http_error
      attach.state = AttachmentByUrl::FAILED
      attach.state_text = http_error.message
      attach.save!
    end

    class << self
      def download(attachment_by_url_id)
        new(attachment_by_url_id).download
      end
    end

    private

    def guess_extension(content_type)
      Redmine::MimeType::MIME_TYPES[content_type].to_s.split(',').first || "unknown"
    end

    def guess_file_name(content_type)
      uri = URI.parse(attach.url)
      base_name = (m = /\/?([^\/]+)$/.match(uri.path)) ? m[1] : "noname"
      /\./ =~ base_name ? base_name : "#{base_name}.#{guess_extension(content_type)}"
    end

  end
end
