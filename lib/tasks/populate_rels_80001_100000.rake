namespace :db do
	task :populate_rels_80001_100000 => :environment do
		puts "Adding relationships 80001_100000..."
	    inFile = File.new("lib/data/Relationships80001-100000.tsv",'r')
	    count = 80001
	    #start the id  set manually
	    next_id = 100080001
	    puts inFile
	    inFile.each { |line|
	      data = line.split('\n')      
	      data.each { |relationship|
	        relData = relationship.split("\t")
	        person1_input = relData[0].to_i+10000000
	        person2_input = relData[1].to_i+10000000
	        created_by_input = User.for_email("odnb_admin@example.com")[0].id
	        approved_by_input = User.for_email("odnb_admin@example.com")[0].id
	        approved_on_input = Time.now
	        max_certainty_input = relData[2]
			puts "max_certainty_input" + max_certainty_input
	        original_certainty_input = relData[2]
	        edge_birthdate_certainty_in = relData[3]
	        puts "edge_birthdate_certainty" + edge_birthdate_certainty_in   
	        puts count
	        count += 1
	        puts "next_id1 = " + next_id.to_s

	       	a_rel = Relationship.new do |r| 
				r.id = next_id
				r.person1_index = person1_input
				r.person2_index = person2_input
				r.created_by = created_by_input
				r.approved_by = approved_by_input
				r.approved_on = approved_on_input
				r.is_approved = true
				r.original_certainty = original_certainty_input
				r.max_certainty = max_certainty_input
				r.edge_birthdate_certainty = edge_birthdate_certainty_in
				r.save!
        	end

        	#increment the manual id
        	next_id = (next_id.to_i + 1)
	       }
	     }
	     puts count
	    inFile.close
	    puts "Finished adding relationships 80001_100000"
	end
end