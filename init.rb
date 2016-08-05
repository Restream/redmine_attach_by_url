Redmine::Plugin.register :redmine_attach_by_url do
  name 'Redmine Attachment By URL Plugin'
  author 'Restream'
  description 'This plugin enables attaching files to issues by URL.'
  version '1.0.2'
  url 'https://github.com/Restream/redmine_attach_by_url'
  author_url 'https://github.com/Restream'

  permission :attach_by_url,
             { attachments_by_url: [:create, :state, :destroy] },
             public: true
end

# Require plugin after register
require 'redmine_attach_by_url'
