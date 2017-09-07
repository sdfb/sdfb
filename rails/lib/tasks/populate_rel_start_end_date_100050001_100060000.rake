namespace :db do
	task :populate_rel_start_end_date_100050001_100060000 => :environment do 
		#for each relationship, update the start and end date based on the birthdates of the people in the relationship
		puts "Updating the start date and end date of each relationship..."
		
    	for i in 100050001..100060000
			relationship_record = Relationship.find(i) 
			birth_year_1 = nil
			death_year_1 = nil
			birth_year_2 = nil
			death_year_2 = nil
			if (! relationship_record.nil?)
				#figure out what the birthdates and deathdates of the people are
				#puts "Finding birth year and death year ..."
			    count = 0
			    person1_index = relationship_record.person1_index.to_i
			    person2_index = relationship_record.person2_index.to_i
			    if (! person1_index.nil?) && (! person2_index.nil?)
				    inFile = File.new("lib/data/people_birth_death_years.tsv",'r')
				    inFile.each { |line|
				    	count += 1
				    	data = line.split('\n')

					    data.each { |person|
					    	# puts "i: " + i.to_s + " count: " + count.to_s
					    	#loop through the people list to locate the person
					    	if ((birth_year_1.nil?) || (birth_year_2.nil?))
						        personData = person.split("\t")
						        person_id = personData[0]
						        # puts "person id: " + person_id.to_s + " rel person 1 id: " + person1_index.to_s + " rel person 2 id: " + person2_index.to_s
						        if (person_id.to_i == person1_index)
						        	birth_year_1 = personData[1]
									death_year_1 = personData[2]
									# puts "birth_year_1: " + birth_year_1.to_s
									# puts "death_year_1: " + birth_year_1.to_s
						        end
						        if (person_id.to_i == person2_index)
						        	birth_year_2 = personData[1]
									death_year_2 = personData[2]
									# puts "birth_year_2" + birth_year_2.to_s
									# puts "death_year_2" + birth_year_2.to_s
						        end
						    else
						    	#puts "break"
						    	break
						    end
				       	}
				    }
				    inFile.close

					#decide new relationship start date
					if ((! birth_year_1.nil?) || (! birth_year_2.nil?))
						##if there is a birthdate for at least 1 person
						new_start_year_type = "AF/IN"
						if ((! birth_year_1.nil?) && (! birth_year_2.nil?))
							## Use max birth year if birthdates are recorded for both people because the relationship can't start before someone is born
							if birth_year_1 > birth_year_2
								new_start_year = birth_year_1.to_i
							else
								new_start_year = birth_year_2.to_i
							end
						elsif (! birth_year_1.blank?)
							new_start_year = birth_year_1.to_i
						elsif (! birth_year_2.nil?)
							new_start_year = birth_year_2.to_i
						end
					else
						##if there is no birthdates, set start date to the default CA 1400 (around 1400)
						new_start_year_type = "CA"
						new_start_year = 1400
					end

					#decide new relationship end date
					if ((! death_year_1.nil?) || (! death_year_2.nil?))
						##if there is a deathdate for at least 1 person
						new_end_year_type = "BF/IN"
						if ((! death_year_1.nil?) && (! death_year_2.nil?))
							## Use min deathdate if deathdates are recorded for both people because the relationship will end by the time of the people dies
							if death_year_1 < death_year_2
								new_end_year = death_year_1.to_i
							else
								new_end_year = death_year_2.to_i
							end
						elsif (! death_year_1.nil?)
							new_end_year = death_year_1.to_i
						elsif (! death_year_2.nil?)
							new_end_year = death_year_2.to_i
						end
					else
						##If there is no death year, set end year to the default CA 1800 (around 1800)
						new_end_year_type = "CA"
						new_end_year = 1800
					end
					# puts i
					# puts "" + new_start_year.to_s
					# puts "" + new_end_year.to_s
					Relationship.update(i, start_year: new_start_year, start_date_type: new_start_year_type, end_year: new_end_year, end_date_type: new_end_year_type)
					puts "updated rel: " + i.to_s + "birth_year_1:" + birth_year_1.to_s + " start_year:" + new_start_year.to_s + "birth_year_2:" + birth_year_2.to_s + " end_year:" + new_end_year.to_s
				end
			end
    	end
	end
end