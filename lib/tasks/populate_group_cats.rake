namespace :db do
  # creating a rake task within db namespace called 'populate_group_cats'
  # executing 'rake db:populate_group_cats' will cause this script to run
  task :populate_group_cats => :environment do 
    puts "Adding group categories..."
    inFile = File.new("lib/data/group_categories.tsv",'r')
    count = 0
    puts inFile
    inFile.each { |line|
      data = line.split('\n')
      data.each { |group_cat|
        groupCatData = group_cat.split("\t")
        id_input = groupCatData[0]
        name_input = groupCatData[1]
        created_by_input = User.for_email("sdfb_admin@example.com")[0].id
        approved_by_input = User.for_email("sdfb_admin@example.com")[0].id
        approved_on_input = Time.now
        count += 1

        a_group = GroupCategory.new do |g| 
          g.id = id_input
          g.name = name_input
          g.is_approved = true
          g.created_by = created_by_input
          g.approved_by = approved_by_input
          g.approved_on = approved_on_input
          g.save!
        end
        puts name_input
        puts count
       }
     }
     puts count
    inFile.close
    puts "Finished adding group categories"
  end
end