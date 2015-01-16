require 'redmine'

Rails.configuration.to_prepare do
  require_dependency 'issue'
  unless Issue.included_modules.include? RedmineAttachByUrl::IssuePatch
    Issue.send :include, RedmineAttachByUrl::IssuePatch
  end
end

require 'redmine_attach_by_url/inflections'
require 'redmine_attach_by_url/hooks'
require 'redmine_attach_by_url/view_hooks'
require 'redmine_attach_by_url/attachment_by_url_presenter'

#require 'delayed_job'
#Delayed::Worker.backend = :active_record
Delayed::Worker.max_attempts = 1
Delayed::Worker.max_run_time = 10.minutes

Redmine::Plugin.register :redmine_attach_by_url do
  name 'Redmine Attachment By URL Plugin'
  author 'Undev'
  description 'Attach files to issues by URL.'
  version '0.1.4'
  url 'https://github.com/nodecarter/redmine_attach_by_url'
  author_url 'https://github.com/nodecarter'

  permission :attach_by_url,
             { :attachments_by_url => [:create, :state, :destroy] },
             :public => true
end
