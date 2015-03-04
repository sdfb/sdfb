namespace :db do
  # executing 'rake db:populate_people_display_names' will cause this script to run
  task :populate_people_display_names => :environment do 
    puts "Updating people's display names..."
    for i in 10000001..10013309
      person_record = Person.find(i)  
      if (! person_record.nil?)
       # # if (person_record.display_name.nil?)
       #    display_name_input = person_record.get_person_name
       #    Person.update(i, display_name: display_name_input)
       #    puts display_name_input
       #  end
      end
    end
    puts "Finished updating people's display names"
  end
end