module RedmineAttachByUrl
  class Downloader
    attr_reader :url, :file_name, :description, :issue_id, :author_id

    def initialize(url, file_name, description, issue_id, author_id)
      @url, @file_name, @description, @issue_id, @author_id =
        url, file_name, description, issue_id, author_id
    end

    def perform
      download_attachment do |file|
        # todo: file.original_filename ???
        attachment = {
          'file' => file,
          'description' => description
        }
        issue.save_attachments [attachment], author
      end
    end

    def on_permanent_failure
      raise "download failure"
    end

    private

    def issue
      @issue ||= Issue.find(issue_id)
    end

    def author
      @author ||= User.find(author_id)
    end

    def download_attachment(&block)
      validate_url!
      validate_file_name!
      uri = URI(url)
      tempfile = UploadedTempfile.new('attach_by_url')
      begin
        open(uri) do |response|
          tempfile.write(response.read)
        end
        yield(tempfile)
      ensure
        tempfile.close
        tempfile.unlink
      end
    end

    def validate_url!
      raise "URL wrong!"
    end

    def validate_file_name!
      raise "file name wrong!"
    end
  end
end
