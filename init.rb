require 'redmine'

require 'redmine_attach_by_url/hooks'

Redmine::Plugin.register :redmine_attach_by_url do
  name 'Redmine Attach By Url plugin'
  author 'Danil Tashkinov'
  description 'This is a plugin for Redmine for attaching files to issue by url'
  version '0.0.1'
  url 'https://github.com/nodecarter/redmine_attach_by_url'
  author_url 'https://github.com/Undev'
end
