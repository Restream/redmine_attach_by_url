require 'redmine'

require 'redmine_attach_by_url/inflections'
require 'redmine_attach_by_url/hooks'
require 'redmine_attach_by_url/view_hooks'

require 'delayed_job'
Delayed::Worker.backend = :active_record
Delayed::Worker.max_attempts = 1
Delayed::Worker.max_run_time = 10.minutes

Redmine::Plugin.register :redmine_attach_by_url do
  name 'Redmine Attach By Url plugin'
  author 'Danil Tashkinov'
  description 'This is a plugin for Redmine for attaching files to issue by url'
  version '0.0.1'
  url 'https://github.com/nodecarter/redmine_attach_by_url'
  author_url 'https://github.com/Undev'
end
