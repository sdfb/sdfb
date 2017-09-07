namespace :db do
	task :populate_rel_sum => :environment do 
		#for each person, make a rel_sum from the existing rel_sum
		puts "Updating the relationship summary..."
    	for i in 10000001..10013309
			person_record = Person.find(i)  
			if (! person_record.nil?)
				#get the existing relsum
				person_rel_sum = person_record.rel_sum
				#new rel_sum
				if (! person_rel_sum.nil?)
					new_rel_sum = []
					person_rel_sum.each do |rel_record|
						new_rel_record = []
						new_rel_record.push(rel_record[0])
						new_rel_record.push(rel_record[1])
						new_rel_record.push(rel_record[3])
						new_rel_record.push(rel_record[4])
						new_rel_record.push(rel_record[5])
						new_rel_sum.push(new_rel_record)
					end
					puts i
					puts new_rel_sum
					Person.update(i, rel_sum: new_rel_sum)
				end
			end
    	end
	end
end