namespace :db do
  desc "Erase and fill database"
  # creating a rake task within db namespace called 'populate'
  # executing 'rake db:populate' will cause this script to run
  task :populate => :environment do
    # Invoke rake db:migrate just in case...
    # Rake::Task['db:migrate:reset'].invoke #commented this out so that it does not reset the database and two populate files can run
    
    # Read in People     
    puts "Adding People..."
    inFile = File.new("lib/data/people.csv",'r')
    count = 0
    inFile.each { |line|
      data = line.split('\n')
      data.each { |person|
        personData = person.split(",")
        original_id_input = personData[0]
        first_name_input = personData[1]
        last_name_input = personData[2]
        birth_year_input = personData[3]
        death_year_input = personData[4]
        historical_sig_input = personData[5]
        count += 1
        puts first_name_input + " " + last_name_input
        Person.create(original_id: original_id_input, first_name: first_name_input, last_name: last_name_input, 
          birth_year: birth_year_input, death_year: death_year_input, historical_significance: historical_sig_input, is_approved: true)
       }
     }
     puts count
    inFile.close
    puts "Finished adding People"
  end
end