class RemovePersonListFromGroup < ActiveRecord::Migration
  def change
    remove_column :groups, :person_list, :text, default: "--- []\n"
  end
end
