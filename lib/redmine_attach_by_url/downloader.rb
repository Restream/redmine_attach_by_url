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

    def perform2
      issue = Issue.find(issue_id)
      author = User.find(author_id)
      journal = issue.init_journal(author)
      begin
        self.class.validate_url!(url)
        file = download_attachment
        begin
          attachment = {
            'file' => file,
            'description' => description
          }
          issue.save_attachments [attachment], author
          if issue.unsaved_attachments.any?
            issue.unsaved_attachments.each do |attach|
              raise attach.errors.full_messages.join(", ")
            end
          else
            journal.notes = I18n.t(:message_download_success, :url => url)
          end
          issue.save!
        ensure
          file.close
        end
      rescue RuntimeError => e
        Rails.logger.error "Download from '#{url}' failed with: #{e.inspect}"
        journal.notes = I18n.t(:message_download_failed, :url => url)
        issue.save!
      end
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
      uri = URI.parse(url)
      base_name = (m = /\/?([^\/]+)$/.match(uri.path)) ? m[1] : "noname"
      /\./ =~ base_name ? base_name : "#{base_name}.#{guess_extension(content_type)}"
    end

    def download_attachment(&block)
      uri = URI.parse(url)
      response = uri.open
      response.extend OriginalFilename
      response.original_filename =
          file_name.blank? ? guess_file_name(response.content_type) : file_name
      response
    end
  end
end
