class RemoveLargeDataTable < ActiveRecord::Migration
  def up
    drop_table :large_data
  end
  def down
    create_table :large_data do |t|
      t.string   "table_file_name"
      t.string   "table_content_type"
      t.integer  "table_file_size"
      t.datetime "file_uploaded_at"
      t.string   "file_path"
      t.string   "upload_data"
      t.integer  "created_by"
    end
  end
end
