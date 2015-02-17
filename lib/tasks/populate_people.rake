namespace :db do
  desc "Erase and fill database"
  # creating a rake task within db namespace called 'populate_people'
<<<<<<< HEAD
  # executing 'rake db:populate_people' will cause this script to run task :populate_people => :environment do
=======
  # executing 'rake db:populate_people' will cause this script to run
  task :populate_people => :environment do
>>>>>>> 8bd2ca1ff5d03c3cfb7a1d4e2674fc3c008d44f5
    # Invoke rake db:migrate just in case...
    # Rake::Task['db:migrate:reset'].invoke #commented this out so that it does not reset the database and two populate files can run

    puts "Adding People..."
    inFile = File.new("lib/data/people.tsv",'r')
    count = 0
    inFile.each { |line|
      data = line.split('\n')
      data.each { |person|
        personData = person.split("\t")
        original_id_input = personData[0]
        puts original_id_input
        if personData[2] != "N/A"
          odnb_id_input = personData[2]
        else
          odnb_id_input = nil
        end
        #puts "ODNB input: " + odnb_id_input
        prefix_input = personData[3]
        #puts "Prefix: " + prefix_input
        first_name_input = personData[4]
        #puts "First name: " + first_name_input
        last_name_input = personData[5]
        #puts "Last name: " + last_name_input
        suffix_input = personData[6]
        #puts "suffix: " + suffix_input
        search_names_input = personData[9]
        #puts "search_names_input: " + search_names_input
        title_input = personData[7]
        #puts "title_input: " + title_input
        birth_year_type_input = personData[19]
        #puts "birth_year_type_input: " + birth_year_type_input 
        death_year_type_input = personData[22]
        #puts "death_year_type_input: " + death_year_type_input
        ext_birth_year_input = personData[20]
        #puts "ext_birth_year_input: " + ext_birth_year_input
        ext_death_year_input = personData[23]
        #puts "ext_death_year_input: " + ext_death_year_input
        alt_birth_year_input = personData[21]
        #puts "alt_birth_year_input" + alt_birth_year_input
        alt_death_year_input = personData[24]
        #puts "alt_death_year_input: " + alt_death_year_input
        historical_sig_input = personData[26]
        #puts "historical_sig_input: " + historical_sig_input
        created_by_input = User.for_email("odnb_admin@example.com")[0].id
        #puts "Created by input: " + created_by_input.to_s
        approved_by_input  = User.for_email("odnb_admin@example.com")[0].id
        #puts "approved_by_input: " + approved_by_input.to_s
        approved_on_input = Time.now
        #puts "approved_on_input: " + approved_on_input.to_s
        rel_sum_input = nil
        count += 1
        puts first_name_input + " " + last_name_input

        a_person = Person.new do |p| 
          p.id = original_id_input
          p.odnb_id = odnb_id_input
          p.prefix = prefix_input
          p.first_name = first_name_input
          p.last_name = last_name_input
          p.suffix = suffix_input
          p.title = title_input
          p.gender = "unknown"
          p.search_names_all = search_names_input 
          p.birth_year_type = birth_year_type_input
          p.ext_birth_year = ext_birth_year_input
          p.alt_birth_year = alt_birth_year_input
          p.death_year_type = death_year_type_input
          p.ext_death_year = ext_death_year_input
          p.alt_death_year = alt_death_year_input 
          p.historical_significance = historical_sig_input
          p.rel_sum = rel_sum_input
          p.is_approved = true
          p.created_by = created_by_input
          p.approved_by = approved_by_input
          p.approved_on = approved_on_input
          # p.save(:validate => false)
          p.save!
        end

        # puts Person.for_odnb_id(odnb_id_input)[0].id;
       }

    }
    puts count
    inFile.close
    puts "Finished adding People"
  end
<<<<<<< HEAD
end
=======
end
>>>>>>> 8bd2ca1ff5d03c3cfb7a1d4e2674fc3c008d44f5
