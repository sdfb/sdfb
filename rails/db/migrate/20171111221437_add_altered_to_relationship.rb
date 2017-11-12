class AddAlteredToRelationship < ActiveRecord::Migration
  def up
    add_column :relationships, :altered, :boolean, default: false
    Relationship.reset_column_information
    Relationship.all.each do |relationship|
      relationship.altered =  (relationship.created_by && relationship.created_by != 2) || relationship.user_rel_contribs.where("created_by != ?",3).count > 0
    end
  end

  def down
    remove_column :relationships, :altered, :boolean, default: false
  end
end
