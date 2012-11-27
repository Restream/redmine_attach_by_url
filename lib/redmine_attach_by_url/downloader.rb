require 'open-uri'

module RedmineAttachByUrl
  module OriginalFilename
    attr_accessor :original_filename
  end

  class Downloader
    attr_reader :url, :file_name, :description, :issue_id, :author_id

    def initialize(url, file_name, description, issue_id, author_id)
      @url, @file_name, @description, @issue_id, @author_id =
        url, file_name, description, issue_id, author_id
    end

    def perform
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

      def perform(url, file_name, description, issue_id, author_id)
        new(url, file_name, description, issue_id, author_id).perform
      end

      def validate_url!(url)
        # uri valid?
        uri = URI.parse(url)

        # allow only http and https
        raise "allow only http and https" unless /^https?$/ =~ uri.scheme

        # deny localhost
        raise "deny localhost" if /^localhost?$/ =~ uri.host

        # deny private networks
        if Regexp.new(uri.parser.pattern[:IPV4ADDR]) =~ uri.host
          private_re = /(^0\.0\.0\.0)|(^127\.0\.0\.1)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)/
          raise "deny private networks" if private_re =~ uri.host
        end
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
