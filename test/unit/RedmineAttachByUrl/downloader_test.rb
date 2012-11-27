require File.dirname(__FILE__) + '/../../test_helper'

class RedmineAttachByUrl::DownloaderTest < ActionController::TestCase
  def test_validate_urls
    valid_urls = %w(
      http://example.com
      http://example.com/
      http://example.com/some/path/pic
      http://example.com/some/path/pic?param=value&another=value
      http://example.com/some/path/pic.png
      http://example.com/some/path/pic.png?param=value&another=value
      https://example.com/some/path/pic.png?param=value&another=value
    )

    not_valid_urls = %w(
      somefile.txt
      file:://somefile.txt
      http:://localhost/somefile.txt
      http:://0.0.0.0/somefile.txt
      http:://127.0.0.1/somefile.txt
      http:://192.168.1.1/somefile.txt
      http:://localhost/somefile.txt
    )

    assert_nothing_raised do
      valid_urls.each do |url|
         RedmineAttachByUrl::Downloader.validate_url!(url)
      end
    end

    assert_raise do
      not_valid_urls.each do |url|
        RedmineAttachByUrl::Downloader.validate_url!(url)
      end
    end
  end

  def test_guess_filename
    urls_map = {
      "http://example.com" => "noname.jpg",
      "http://example.com/" => "noname.jpg",
      "http://example.com/some/path/pic" => "pic.jpg",
      "http://example.com/some/path/pic?param=value&another=value" => "pic.jpg",
      "http://example.com/some/path/pic.jpg" => "pic.jpg",
      "http://example.com/some/path/pic.jpg?param=value&another=value" => "pic.jpg",
      "https://example.com/some/path/pic.jpg?param=value&another=value" => "pic.jpg"
    }
    urls_map.each do |url, file_name|
      downloader = RedmineAttachByUrl::Downloader.new(url, nil, nil, nil, nil)
      guessed_file_name = downloader.send(:guess_file_name, 'image/jpeg')
      assert_equal file_name, guessed_file_name
    end
  end
end
