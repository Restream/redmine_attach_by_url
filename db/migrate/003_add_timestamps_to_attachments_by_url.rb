class AddTimestampsToAttachmentsByUrl < ActiveRecord::Migration
  def self.up
    add_timestamps :attachments_by_url
  end

  def self.down
    remove_timestamps :attachments_by_url
  end
end
