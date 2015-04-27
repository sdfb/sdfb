namespace :db do
	task :populate_rel_start_end_date_101030_176542 => :environment do 
		#for each relationship, update the start and end date based on the birthdates of the people in the relationship
		puts "Updating the start date and end date of each relationship..."

		problem_list = [100003942,100006369,100007211,100009361,100009458,100009485,100009486,100009487,100009488,100009489,100009490,100009491,100009492,100009493,100009494,100009495,100009496,100009497,100009498,100009499,100009500,100009501,100009502,100009503,100009504,100009505,100009506,100009507,100009508,100009509,100009510,100009511,100009512,100009513,100009514,100009515,100009516,100009517,100009518,100009519,100009520,100009521,100009522,100009523,100009524,100009525,100009526,100009527,100009528,100009529,100009530,100009531,100009532,100009533,100009534,100009535,100009536,100009537,100009538,100009539,100009540,100009541,100009542,100009543,100009544,100009545,100009546,100009547,100009548,100009549,100009550,100009551,100009552,100009553,100009554,100009555,100009556,100009557,100009558,100009559,100009560,100009561,100009562,100009563,100009564,100009565,100009566,100009567,100009568,100009569,100009570,100009571,100009572,100009573,100009574,100009575,100009576,100009577,100009578,100009579,100009580,100009581,100009582,100009583,100009584,100009585,100009586,100009587,100009588,100009589,100009590,100009591,100009592,100009593,100009594,100009595,100009596,100009597,100009598,100009599,100009600,100009601,100009602,100009603,100009604,100009605,100009606,100009607,100009608,100009609,100009610,100009611,100009612,100009613,100009614,100009615,100009616,100009617,100009618,100009619,100009620,100009621,100009622,100009623,100009624,100009625,100009626,100009627,100009628,100009629,100009630,100009631,100009632,100009633,100009634,100009635,100009636,100009637,100009638,100009639,100009640,100009641,100009642,100009643,100009644,100009645,100009646,100009647,100009648,100009649,100009650,100009651,100009652,100009653,100009654,100009655,100009656,100009657,100009658,100009659,100009660,100009661,100009662,100009663,100009664,100009665,100009666,100009667,100009668,100009669,100009670,100009671,100009672,100009673,100009674,100009675,100009676,100009677,100009678,100009679,100009680,100009681,100009682,100009683,100009684,100009685,100009686,100009687,100009688,100009689,100009690,100009691,100009692,100009693,100009694,100009695,100009696,100009697,100009698,100009699,100009700,100009701,100009702,100009703,100009704,100009705,100009706,100009707,100009708,100009709,100009710,100009711,100009712,100009713,100009714,100009715,100009716,100009717,100009718,100009719,100009720,100009721,100009722,100009723,100009724,100009725,100009726,100009727,100009728,100009729,100009730,100009731,100009732,100009733,100009734,100009735,100009736,100009737,100009738,100009739,100009740,100009741,100009742,100009743,100009744,100009745,100009746,100009747,100009748,100009749,100009750,100009751,100009752,100009753,100009754,100009755,100009756,100009757,100009758,100009759,100019846,100020367,100022939,100027777,100032522,100035674,100036246,100036264,100050293,100056747,100056878,100058582,100060916,100061238,100063450,100064702,100068419,100070219,100074856,100082013,100088072,100093012,100095325,100098428,100101032,100101036,100101831,100103742,100108946,100111288,100111315,100113571,100115964,100115995,100118454,100118701,100119694,100122514,100124614,100125535,100127055,100129295,100130442,100132651,100132807,100137696,100137765,100138772,100139452,100141632,100142112,100142484,100144123,100145335,100145428,100145432,100150407,100151961,100155255,100155291,100155718,100156040,100159634,100160339,100161899,100162548,100162781,100163323,100165461,100165845,100165846,100166054,100166828,100167402,100167684,100168467,100169421,100169991,100169999,100170005,100170065,100170074,100170075,100170076,100170077,100170078,100170079,100170080,100170081,100170082,100170083,100165267]
    	
    	for i in 100101030..100176542
    		if (! problem_list.include?(i))
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
end