class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :description
      t.string :comment_type
      t.integer :associated_contrib
      t.integer :created_by

      t.timestamps
    end
  end
end
