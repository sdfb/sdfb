namespace :db do
  # creating a rake task within db namespace called 'populate_group_cats_assigns'
  # executing 'rake db:populate_group_cats_assigns' will cause this script to run
  task :populate_group_cat_assigns => :environment do 
    puts "Adding group category assignments..."
    inFile = File.new("lib/data/group_cat_assignments.tsv",'r')
    count = 0
    puts inFile
    inFile.each { |line|
      data = line.split('\n')
      data.each { |group_cat_assign|
        groupCatAssignData = group_cat_assign.split("\t")
        group_input = groupCatAssignData[0]
        group_category_input = groupCatAssignData[1]
        created_by_input = User.for_email("sdfbadmin@example.com")[0].id
        approved_by_input = User.for_email("sdfbadmin@example.com")[0].id
        approved_on_input = Time.now
        count += 1

        a_group = GroupCatAssign.new do |g| 
          g.group_id = group_input
          g.group_category_id = group_category_input
          g.is_approved = true
          g.created_by = created_by_input
          g.approved_by = approved_by_input
          g.approved_on = approved_on_input
          g.save!
        end
        puts count
       }
     }
     puts count
    inFile.close
    puts "Finished adding group category assignments"
  end
end