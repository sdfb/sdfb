namespace :db do
  # creating a rake task within db namespace called 'populate_rel_certain'
  # executing 'rake db:populate_rel_certain' will cause this script to run
  task :populate_rel_certain => :environment do
    # Read in Certain relationships    
    puts "Adding Certain Relationships..."
    inFile = File.new("lib/data/rel_certain.csv",'r')
    count = 0
    puts inFile
    inFile.each { |line|
      data = line.split('\n')
      data.each { |relationship|
        relData = relationship.split(",")
        puts relData[0].to_i+10000000
        puts relData[1].to_i+10000000
        person1_input = relData[0].to_i+10000000
        person2_input = relData[1].to_i+10000000
        created_by_input = User.for_email("admin@example.com")[0].id
        approved_by_input = User.for_email("admin@example.com")[0].id
        approved_on_input = Time.now
        count += 1
        puts count

        Relationship.create(person1_index: person1_input, person2_index: person2_input, 
          created_by: created_by_input, approved_by: approved_by_input, approved_on: approved_on_input,
          original_certainty: 0.95, max_certainty: 0.95)
       }
     }
     puts count
    inFile.close
    puts "Finished adding 'Certain' Relationships"
  end
end