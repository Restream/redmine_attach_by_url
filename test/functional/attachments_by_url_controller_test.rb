require File.expand_path('../../test_helper', __FILE__)

class AttachmentsByUrlControllerTest < ActionController::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :trackers,
           :projects_trackers,
           :enabled_modules,
           :issue_statuses,
           :issues,
           :enumerations

  def setup
    @url = 'http://example.com/pic.png'

    User.current = User.find(2)
    @request.session[:user_id] = 2

    # switch off delayed_job
    RedmineAttachByUrl::Downloader.class_eval "def self.delay() return self end"
    RedmineAttachByUrl::Downloader.stubs(:download).returns(nil)
    @attach_by_url = RedmineAttachByUrl::DownloadService.download_start(@url, User.current)
    @attach_by_url.state = AttachmentByUrl::IN_PROGRESS
    @attach_by_url.save!
  end

  def test_attachment_queued_with_valid_url
    %w(
      http://example.com
      http://example.com/
      http://example.com/some/path/pic
      http://example.com/some/path/pic?param=value&another=value
      http://example.com/some/path/pic.png
      http://example.com/some/path/pic.png?param=value&another=value
      https://example.com/some/path/pic.png?param=value&another=value
    ).each do |url|
      attrs = { :url => url }
      post :create, :attachment_by_url => attrs
      assert_response :success
      json_response = ActiveSupport::JSON.decode(@response.body)
      assert json_response
      assert_equal AttachmentByUrl::QUEUED, json_response['state']
    end
  end

  def test_attachment_failed_with_invalid_url
    %w(
      somefile.txt
      file:://somefile.txt
      http:://localhost/somefile.txt
      http:://0.0.0.0/somefile.txt
      http:://127.0.0.1/somefile.txt
      http:://192.168.1.1/somefile.txt
    ).each do |url|
      attrs = { :url => url }
      post :create, :attachment_by_url => attrs
      assert_response :success
      json_response = ActiveSupport::JSON.decode(@response.body)
      assert json_response
      assert_equal AttachmentByUrl::FAILED,
                   json_response['state'],
                   "state for url '#{url}' must be failed"
    end
  end

  def test_attachment_state
    get :state, :id => @attach_by_url.id
    assert_response :success
    json_response = ActiveSupport::JSON.decode(@response.body)
    assert json_response
    assert_equal AttachmentByUrl::IN_PROGRESS, json_response['state']
  end

  def test_attachment_cancel
    delete :destroy, :id => @attach_by_url.id
    assert_response :success
    json_response = ActiveSupport::JSON.decode(@response.body)
    assert json_response
    assert_equal AttachmentByUrl::CANCELED, json_response['state']
  end
end
