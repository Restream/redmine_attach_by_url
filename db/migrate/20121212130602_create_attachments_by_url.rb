class CreateAttachmentsByUrl < ActiveRecord::Migration
  def self.up
    create_table :attachments_by_url, force: true do |t|
      t.column :url, :string
      t.column :state, :string
      t.column :state_text, :string
      t.column :complete_bytes, :integer
      t.column :total_bytes, :integer
    end
  end

  def self.down
    drop_table :attachments_by_url
  end
end
