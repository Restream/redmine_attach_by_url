class AddAttachmentToAttachmentsByUrl < ActiveRecord::Migration
  def self.up
    add_column :attachments_by_url, :attachment_id, :integer
  end

  def self.down
    remove_column :attachments_by_url, :attachment_id
  end
end
