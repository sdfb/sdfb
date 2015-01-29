namespace :db do
  # creating a rake task within db namespace called 'populate_rel_cats_assigns'
  # executing 'rake db:populate_rel_cats_assigns' will cause this script to run
  task :populate_rel_cat_assigns => :environment do 
    puts "Adding relationship category assignments..."
    inFile = File.new("lib/data/rel_cat_assignments.tsv",'r')
    count = 0
    puts inFile
    inFile.each { |line|
      data = line.split('\n')
      data.each { |rel_cat_assign|
        relCatAssignData = rel_cat_assign.split("\t")
        rel_type_input = relCatAssignData[0]
        rel_category_input = relCatAssignData[1]
        created_by_input = User.for_email("sdfb_admin@example.com")[0].id
        approved_by_input = User.for_email("sdfb_admin@example.com")[0].id
        approved_on_input = Time.now
        count += 1

        a_rel_cat_assign = RelCatAssign.new do |rca| 
          rca.relationship_type_id = rel_type_input
          rca.relationship_category_id = rel_category_input
          rca.is_approved = true
          rca.created_by = created_by_input
          rca.approved_by = approved_by_input
          rca.approved_on = approved_on_input
          rca.save!
        end
        puts count
       }
     }
     puts count
    inFile.close
    puts "Finished adding relationship category assignments"
  end
end