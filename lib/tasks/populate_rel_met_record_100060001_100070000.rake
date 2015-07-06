namespace :db do
	task :populate_rel_met_record_100060001_100070000 => :environment do 
		#for each relationship, update the start and end date based on the birthdates of the people in the relationship
		puts "Creating a met record for each relationship..."
		
    	for i in 100060001..100070000
			Relationship.update(i, is_active: true)
			puts "created met record for relationship: " + i.to_s
    	end
	end
end