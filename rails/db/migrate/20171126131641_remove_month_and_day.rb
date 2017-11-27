class RemoveMonthAndDay < ActiveRecord::Migration
  def change
    remove_column :group_assignments, :start_month, :string
    remove_column :group_assignments, :start_day, :integer
    remove_column :group_assignments, :end_month, :string
    remove_column :group_assignments, :end_day, :integer

    remove_column :relationships, :start_month, :string
    remove_column :relationships, :start_day, :integer
    remove_column :relationships, :end_month, :string
    remove_column :relationships, :end_day, :integer

    remove_column :user_rel_contribs, :start_month, :string
    remove_column :user_rel_contribs, :start_day, :integer
    remove_column :user_rel_contribs, :end_month, :string
    remove_column :user_rel_contribs, :end_day, :integer
  end
end
