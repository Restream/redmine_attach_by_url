require File.expand_path('../../../test_helper', __FILE__)

class RedmineAttachByUrl::IssuesControllerTest < ActionController::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :workflows

  def setup
    @controller = IssuesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user_id] = 1 # admin
  end

  def test_save_attachment_by_url
    set_tmp_attachments_directory
    attach = Attachment.new(
      file:   uploaded_test_file('testfile.txt', 'text/plain'),
      author: User.find(1)
    )
    attach_by_url = AttachmentByUrl.create!(
      url:        'http://example.com/testfile.txt',
      author:     attach.author,
      state:      AttachmentByUrl::COMPLETED,
      attachment: attach
    )

    assert_difference 'Issue.count' do
      post :create, project_id: 1,
           issue:               { tracker_id: '1', subject: 'With attachment by url' },
           attachments_by_url:  [{ id: attach_by_url.id, description: 'test file' }]
    end

    issue = Issue.last
    attachment = Attachment.last

    assert_equal issue, attachment.container
    assert_equal 1, attachment.author_id
    assert_equal 'testfile.txt', attachment.filename
    assert_equal 'text/plain', attachment.content_type
    assert_equal 'test file', attachment.description
    assert_equal 59, attachment.filesize
    assert File.exists?(attachment.diskfile)
    assert_equal 59, File.size(attachment.diskfile)
  end

end
