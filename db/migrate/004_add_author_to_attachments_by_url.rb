class AddAuthorToAttachmentsByUrl < ActiveRecord::Migration
  def self.up
    add_column :attachments_by_url, :author_id, :integer
  end

  def self.down
    remove_column :attachments_by_url, :author_id
  end
end
