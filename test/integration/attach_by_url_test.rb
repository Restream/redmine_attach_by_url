require File.expand_path('../../test_helper', __FILE__)

class AttachByUrlTest < ActionController::IntegrationTest
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

  def test_attach_by_url
    log_user('jsmith', 'jsmith')

    a_file = mock_file
    a_file.expects(:close)
    RedmineAttachByUrl::Downloader.any_instance.stubs(:download_attachment).returns(a_file)

    # switch off delayed_job
    RedmineAttachByUrl::Downloader.class_eval "def self.delay() return self end"

    post 'projects/1/issues', :tracker_id => "1",
        :issue => { :start_date => "2006-12-26",
                    :priority_id => "4",
                    :subject => "issue with file by url",
                    :category_id => "",
                    :description => "issue with file by url",
                    :done_ratio => "0",
                    :due_date => "",
                    :assigned_to_id => "" },
        :attachments_by_url => { '1' => {
            'url' => "http://example.com/a_file/png",
            'description' => 'file by url' } }

    assert_response :redirect

    # find created issue
    issue = Issue.find_by_subject("issue with file by url")
    assert_kind_of Issue, issue
    # make sure attachment was downloaded (stubbed) and saved
    attachment = issue.attachments.find_by_filename(a_file)
    assert_kind_of Attachment, attachment
    assert_equal issue, attachment.container
    assert_equal 'file by url', attachment.description
    # verify that the attachment was written to disk
    assert File.exist?(attachment.diskfile)
  end
end
