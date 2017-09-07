class AddCreatedByToLargeData < ActiveRecord::Migration
  def change
    add_column :large_data, :created_by, :integer
  end
end
