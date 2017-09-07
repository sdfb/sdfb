class AddDisplayNameToPeople < ActiveRecord::Migration
  def change
    add_column :people, :display_name, :string
  end
end
