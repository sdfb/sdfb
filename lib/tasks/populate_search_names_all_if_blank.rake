namespace :db do
  # creating a rake task within db namespace called 'populate_people_genders'
  # executing 'rake db:populate_populate_genders' will cause this script to run
  task :populate_search_names_all_if_blank => :environment do 
    puts "Updating people's search_names_all..."
    for i in 10000001..10013309
      person_record = Person.find(i)  
      if (! person_record.nil?)
        if (person_record.search_names_all == "")
          # Use the display name if there is no search name so that each person has at least 1 name to be searched by
          search_names_all_input = person_record.display_name
          Person.update(i, search_names_all: search_names_all_input)
          puts search_names_all_input
        end
      end
    end
    puts "Finished updating people's search_names_all"
  end
end