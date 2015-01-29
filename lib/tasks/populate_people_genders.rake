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
        gender_input = genderData[1]
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