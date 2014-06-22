namespace :db do
  # creating a rake task within db namespace called 'populate_rel_likely'
  # executing 'rake db:populate_rel_likely' will cause this script to run
  task :populate_rel_likely => :environment do
    # Read in likely relationships    
    puts "Adding Likely Relationships..."
    inFile = File.new("lib/data/rel_likely.csv",'r')
    count = 0
    puts inFile
    inFile.each { |line|
      data = line.split('\n')
      data.each { |relationship|
        relData = relationship.split(",")
        person1_input = Person.for_original_id(relData[0]).first.id
        person2_input = Person.for_original_id(relData[1]).first.id
        count += 1
        puts count
        Relationship.create(person1_index: person1_input, person2_index: person2_input, is_approved: true, original_certainty: 0.85, average_certainty: 0.85)
       }
     }
     puts count
    inFile.close
    puts "Finished adding 'Likely' Relationships"
  end
end