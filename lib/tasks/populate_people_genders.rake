namespace :db do
  # creating a rake task within db namespace called 'populate_people_genders'
  # executing 'rake db:populate_populate_genders' will cause this script to run
  task :populate_people_genders => :environment do 
    puts "Updating people genders..."
    inFile = File.new("lib/data/genders.tsv",'r')
    count = 0
    puts inFile
    inFile.each { |line|
      data = line.split('\n')
      data.each { |genderRecord|
        genderData = genderRecord.split("\t")
        person_id_input = genderData[0]
        if genderData[1] == "male\n"
          gender_input = "male"
        elsif genderData[1] == "female\n"
          gender_input = "female"
        else
          gender_input = "unknown"
        end
        Person.update(person_id_input, gender: gender_input)
        count += 1
        puts count
       }
     }
     puts count
    inFile.close
    puts "Finished updating people genders"
  end
end