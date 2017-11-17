class RemoveRejectedFromCode < ActiveRecord::Migration
  def change
    GroupAssignment.find_by_sql("SELECT * FROM group_assignments WHERE is_rejected").each {|r| r.update_column(:is_active, false)}
    # GroupCatAssign.find_by_sql("SELECT * FROM group_cat_assigns WHERE is_rejected").each {|r| r.update_column(:is_active, false)}
    # GroupCategory.find_by_sql("SELECT * FROM group_categories WHERE is_rejected").each {|r| r.update_column(:is_active, false)}
    Group.find_by_sql("SELECT * FROM groups WHERE is_rejected").each {|r| r.update_column(:is_active, false)}
    Person.find_by_sql("SELECT * FROM people WHERE is_rejected").each {|r| r.update_column(:is_active, false)}
    RelCatAssign.find_by_sql("SELECT * FROM rel_cat_assigns WHERE is_rejected").each {|r| r.update_column(:is_active, false)}
    RelationshipCategory.find_by_sql("SELECT * FROM relationship_categories WHERE is_rejected").each {|r| r.update_column(:is_active, false)}
    RelationshipType.find_by_sql("SELECT * FROM relationship_types WHERE is_rejected").each {|r| r.update_column(:is_active, false)}
    Relationship.find_by_sql("SELECT * FROM relationships WHERE is_rejected").each {|r| r.update_column(:is_active, false)}
    # UserGroupContrib.find_by_sql("SELECT * FROM user_group_contribs WHERE is_rejected").each {|r| r.update_column(:is_active, false)}
    # UserPersonContrib.find_by_sql("SELECT * FROM user_person_contribs WHERE is_rejected").each {|r| r.update_column(:is_active, false)}
    UserRelContrib.find_by_sql("SELECT * FROM user_rel_contribs WHERE is_rejected").each {|r| r.update_column(:is_active, false)}
    remove_column :group_assignments, :is_rejected, :boolean, default: false
    remove_column :group_cat_assigns, :is_rejected, :boolean, default: false
    remove_column :group_categories, :is_rejected, :boolean, default: false
    remove_column :groups, :is_rejected, :boolean, default: false
    remove_column :people, :is_rejected, :boolean, default: false
    remove_column :rel_cat_assigns, :is_rejected, :boolean, default: false
    remove_column :relationship_categories, :is_rejected, :boolean, default: false
    remove_column :relationship_types, :is_rejected, :boolean, default: false
    remove_column :relationships, :is_rejected, :boolean, default: false
    remove_column :user_group_contribs, :is_rejected, :boolean, default: false
    remove_column :user_person_contribs, :is_rejected, :boolean, default: false
    remove_column :user_rel_contribs, :is_rejected, :boolean, default: false
  end
end
