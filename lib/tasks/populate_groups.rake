namespace :db do
  # creating a rake task within db namespace called 'populate_groups'
  # executing 'rake db:populate_groups' will cause this script to run
  task :populate_groups => :environment do 
    puts "Adding groups..."
    inFile = File.new("lib/data/groups.tsv",'r')
    count = 0
    puts inFile
    inFile.each { |line|
      data = line.split('\n')
      data.each { |group|
        groupData = group.split("\t")
        id_input = groupData[0]
        name_input = groupData[1]
        if (! groupData[2].blank?)
           description_input = groupData[2]
        else  
          description_input = '-'
        end
        if (! groupData[3].blank?)
          start_year_input = groupData[3]
          start_date_type_input = "IN"
        else
          start_year_input = nil
          start_date_type_input = nil
        end
        if (! groupData[4].blank?)
          end_year_input = groupData[4]
          end_date_type_input = "IN"
        else
          end_year_input = nil
          end_date_type_input = nil
        end
        created_by_input = User.for_email("sdfb_admin@example.com")[0].id
        approved_by_input = User.for_email("sdfb_admin@example.com")[0].id
        approved_on_input = Time.now
        count += 1

        a_group = Group.new do |g| 
          g.id = id_input
          g.name = name_input
          g.is_approved = true
          g.description = description_input
          g.start_year = start_year_input
          g.start_date_type = start_date_type_input
          g.end_year = end_year_input
          g.end_date_type = end_date_type_input
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
    puts "Finished adding groups"
  end
end