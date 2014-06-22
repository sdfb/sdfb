namespace :db do
  # creating a rake task within db namespace called 'populate_rel_unlikely'
  # executing 'rake db:populate_rel_unlikely' will cause this script to run
  task :populate_rel_unlikely => :environment do
    # Read in unlikely relationships    
    puts "Adding unlikely Relationships..."
    inFile = File.new("lib/data/rel_unlikely.csv",'r')
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
        Relationship.create(person1_index: person1_input, person2_index: person2_input, is_approved: true, original_certainty: 0.15, average_certainty: 0.15)
       }
     }
     puts count
    inFile.close
    puts "Finished adding 'Unlikely' Relationships"
  end
end