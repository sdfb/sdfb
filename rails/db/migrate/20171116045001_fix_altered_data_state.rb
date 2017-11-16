class FixAlteredDataState < ActiveRecord::Migration
  def up
    Relationship.all.each {|r| r.updated_altered_state!}
  end
  def down
    # If you really do want to roll back , you can comment this out
    # it won't really be reversable, since this changes data, but
    # it's not the worst thing thing the data being changed is just
    # a computed field from other data in the table.
    raise ActiveRecord::IrreversibleMigration
  end
end
