class UpdateFlags < ActiveRecord::Migration
  def up
  	remove_column :flags, :flag_type
  end

  def down
  end
end
