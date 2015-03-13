namespace :db do
	task :populate_rel_list => :environment do 
		#for each person, make a rel_list from the existing rel_sum
		puts "Updating people's display names..."
    	for i in 10000001..10013309
			person_record = Person.find(i)  
			if (! person_record.nil?)
				#get the existing relsum
				person_rel_sum = person_record.rel_sum
				#new rel_list
				if (! person_rel_sum.nil?)
					new_rel_list = []
					person_rel_sum.each do |rel_record|
						new_rel_record = []
						new_rel_record.push(rel_record[0])
						new_rel_record.push(rel_record[3])
						new_rel_list.push(new_rel_record)
					end
					puts i
					puts new_rel_list
					Person.update(i, rel_list: new_rel_list)
				end
			end
    	end
	end
end