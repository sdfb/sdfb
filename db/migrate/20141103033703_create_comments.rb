class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :comment_type
      t.integer :associated_contrib
      t.integer :created_by
      t.text :content

      t.timestamps
    end
  end
end
