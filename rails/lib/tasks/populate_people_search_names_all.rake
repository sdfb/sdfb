namespace :db do
  # executing 'rake db:populate_people_search_names_all' will cause this script to run
  task :populate_people_search_names_all => :environment do 
    puts "Updating people's search names all..."
    inFile = File.new("lib/data/people.tsv",'r')
    inFile.each { |line|
      data = line.split('\n')
      data.each { |person|
        personData = person.split("\t")
        search_names_all_input = personData[8]
        #find the person record
        person_record = Person.find(personData[0])  
        if (! person_record.nil?)
          #add all permutations to the search names all  
          if (! person_record.prefix.blank?)
            if (! person_record.first_name.blank?)
              # Prefix FirstName
              search_names_all_input += ", " + person_record.prefix + " " + person_record.first_name
              if (! person_record.last_name.blank?)
                # Prefix FirstName LastName
                search_names_all_input += ", " + person_record.prefix + " " + person_record.first_name + " " + person_record.last_name

                if (! person_record.suffix.blank?)
                  # Prefix FirstName LastName Suffix
                  search_names_all_input += ", " + person_record.prefix + " " + person_record.first_name + " " + person_record.last_name + " " + person_record.suffix
                end
                if (! person_record.title.blank?)
                  # Prefix FirstName LastName Title
                  search_names_all_input += ", " + person_record.prefix + " " + person_record.first_name + " " + person_record.last_name + " " + person_record.title
                end
              end
              if (! person_record.suffix.blank?)
                # Prefix FirstName Suffix
                search_names_all_input += ", " + person_record.prefix + " " + person_record.first_name + " " + person_record.suffix
              end
            end
            if (! person_record.last_name.blank?)
              # Prefix LastName
              search_names_all_input += ", " + person_record.prefix + " " + person_record.last_name
              if (! person_record.suffix.blank?)
                # Prefix LastName Suffix
                search_names_all_input += ", " + person_record.prefix + " " + person_record.last_name + " " + person_record.suffix
              end
            end
          end
          if (! person_record.first_name.blank?)
            # FirstName
            search_names_all_input += ", " + person_record.first_name
            if (! person_record.last_name.blank?)
              # FirstName LastName
              search_names_all_input += ", " + person_record.first_name + " " +  person_record.last_name
              if (! person_record.suffix.blank?)
                # FirstName LastName Suffix
                search_names_all_input += ", " + person_record.first_name + " " + person_record.last_name + " " + person_record.suffix
              end
              if (! person_record.title.blank?)
                # FirstName LastName Title
                search_names_all_input += ", " + person_record.first_name + " " + person_record.last_name + " " + person_record.title
              end
            end
            if (! person_record.suffix.blank?)
              # FirstName Suffix
              search_names_all_input += ", " + person_record.first_name + " " + person_record.suffix
            end
          end
        end
        Person.update(personData[0], search_names_all: search_names_all_input)
        puts search_names_all_input
      }
    }
    puts "Finished updating people's search names all"
  end
end


