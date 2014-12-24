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
  name 'Redmine Attach By Url plugin'
  author 'nodecarter'
  description 'This is a plugin for Redmine for attaching files to issue by url'
  version '1.0.0'
  url 'https://github.com/Undev/redmine_attach_by_url'
  author_url 'https://github.com/nodecarter'

  permission :attach_by_url,
             { :attachments_by_url => [:create, :state, :destroy] },
             :public => true
end
