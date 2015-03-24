namespace :db do
	task :populate_rel_start_end_date_14001_all => :environment do 
		#for each relationship, update the start and end date based on the birthdates of the people in the relationship
		puts "Updating the start date and end date of each relationship..."
    	for i in 100017001..100170542
			relationship_record = Relationship.find(i)  
			if (! relationship_record.nil?)
				#figure out what the birthdates and deathdates of the people are
				person1_record = Person.find(relationship_record.person1_index)
				person2_record = Person.find(relationship_record.person2_index)
				if (! person1_record.nil?)
					birth_year_1 = person1_record.ext_birth_year
					death_year_1 = person1_record.ext_death_year
				end
				if (! person2_record.nil?)
					birth_year_2 = person2_record.ext_birth_year
					death_year_2 = person2_record.ext_death_year
				end

				#decide new relationship start date
				
				if ((! birth_year_1.blank?) || (! birth_year_2.blank?))
					##if there is a birthdate for at least 1 person
					new_start_year_type = "AF/IN"
					if ((! birth_year_1.blank?) && (! birth_year_2.blank?))
						## Use max birth year if birthdates are recorded for both people because the relationship can't start before someone is born
						if birth_year_1 > birth_year_2
							new_start_year = birth_year_1.to_i
						else
							new_start_year = birth_year_2.to_i
						end
					elsif (! birth_year_1.blank?)
						new_start_year = birth_year_1.to_i
					elsif (! birth_year_2.blank?)
						new_start_year = birth_year_2.to_i
					end
				else
					##if there is no birthdates, set start date to the default CA 1400 (around 1400)
					new_start_year_type = "CA"
					new_start_year = 1400
				end

				#decide new relationship end date
				if ((! death_year_1.blank?) || (! death_year_2.blank?))
					##if there is a deathdate for at least 1 person
					new_end_year_type = "BF/IN"
					if ((! death_year_1.blank?) && (! death_year_2.blank?))
						## Use min deathdate if deathdates are recorded for both people because the relationship will end by the time of the people dies
						if death_year_1 < death_year_2
							new_end_year = death_year_1.to_i
						else
							new_end_year = death_year_2.to_i
						end
					elsif (! death_year_1.blank?)
						new_end_year = death_year_1.to_i
					elsif (! death_year_2.blank?)
						new_end_year = death_year_2.to_i
					end
				else
					##If there is no death year, set end year to the default CA 1800 (around 1800)
					new_end_year_type = "CA"
					new_end_year = 1800
				end
				puts i
				puts "" + new_start_year_type
				puts "" + new_end_year_type
				Relationship.update(i, start_year: new_start_year, start_date_type: new_start_year_type, end_year: new_end_year, end_date_type: new_end_year_type)
			end
    	end
	end
end