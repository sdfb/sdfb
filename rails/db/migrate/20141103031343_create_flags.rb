class CreateFlags < ActiveRecord::Migration
  def change
    create_table :flags do |t|
      t.string :assoc_object_type
      t.integer :assoc_object_id
      t.text :flag_description
      t.integer :created_by
      t.integer :resolved_by
      t.datetime :resolved_at

      t.timestamps
    end
  end
end
