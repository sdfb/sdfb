namespace :db do
  # creating a rake task within db namespace called 'populate_groups'
  # executing 'rake db:populate_groups' will cause this script to run
  task :populate_rel_types => :environment do 
    puts "Adding relationship types..."
    inFile = File.new("lib/data/rel_types.tsv",'r')
    count = 0
    puts inFile
    inFile.each { |line|
      data = line.split('\n')
      data.each { |rel_type|
        relTypeData = rel_type.split("\t")
        id_input = relTypeData[0]
        name_input = relTypeData[1]
        rt_inverse_input = relTypeData[2]
        created_by_input = User.for_email("sdfbadmin@example.com")[0].id
        approved_by_input = User.for_email("sdfbadmin@example.com")[0].id
        approved_on_input = Time.now
        count += 1

        a_rel_type = RelationshipType.new do |rt| 
          rt.id = id_input
          rt.name = name_input
          puts rt_inverse_input
          rt.relationship_type_inverse = rt_inverse_input
          rt.is_approved = true
          rt.created_by = created_by_input
          rt.approved_by = approved_by_input
          rt.approved_on = approved_on_input
          rt.save!
        end
        puts name_input
        puts count
       }
     }
     puts count
    inFile.close
    puts "Finished adding relationship types"
  end
end