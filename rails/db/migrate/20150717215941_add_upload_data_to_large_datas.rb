class AddUploadDataToLargeDatas < ActiveRecord::Migration
  def change
    add_column :large_data, :upload_data, :string
  end
end
