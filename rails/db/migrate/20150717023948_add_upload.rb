class AddUpload < ActiveRecord::Migration
  def self.up
  	add_column :large_data, :table_file_name, :string
  	add_column :large_data, :table_content_type, :string
  	add_column :large_data, :table_file_size, :integer
  	add_column :large_data, :file_uploaded_at, :datetime
    add_column :large_data, :file_path, :string
  end

  def self.down
  	remove_column :large_data, :table_file_name, :string
  	remove_column :large_data, :table_content_type, :string
  	remove_column :large_data, :table_file_size, :integer
  	remove_column :large_data, :file_uploaded_at, :datetime
    remove_column :large_data, :file_path, :string
  end
end
