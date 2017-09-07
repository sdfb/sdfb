class CreateLargeData < ActiveRecord::Migration
  def self.up
  	create_table :large_data 
  end

  def self.down
  	drop_table :large_data
  end
end