ActionDispatch::Callbacks.to_prepare do

  # Check that patch applied on every request
  load 'redmine_attach_by_url/issue_patch.rb'

  # Yes, we need delayed_job
  require 'delayed_job'

  # Requiring Redmine hooks
  require 'redmine_attach_by_url/hooks'
  require 'redmine_attach_by_url/view_hooks'

  # Requiring plugin's controller and model
  require_dependency 'attachments_by_url_controller'
  require_dependency 'attachment_by_url'
end

# Initialize inflections
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'attachment_by_url', 'attachments_by_url'
  inflect.irregular 'AttachmentByUrl', 'AttachmentsByUrl'
end

# Initialize delayed jobs
Delayed::Worker.max_attempts = 1
Delayed::Worker.max_run_time = 10.minutes
