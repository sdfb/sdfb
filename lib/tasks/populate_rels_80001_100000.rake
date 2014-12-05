namespace :db do
	task :populate_rels_80001_100000 => :environment do
		puts "Adding relationships 80001_100000..."
	    inFile = File.new("lib/data/Relationships80001-100000.tsv",'r')
	    count = 80000
	    puts inFile
	    inFile.each { |line|
	      data = line.split('\n')
	      data.each { |relationship|
	        relData = relationship.split("\t")
	        #puts relData[0].to_i+10000000
	        #puts relData[1].to_i+10000000
	        # puts "0: " + relData[0]
	        # puts "1: " + relData[1]
	        # puts "2: " + relData[2]
	        # puts "3: " + relData[3]
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
	        count += 1
	        puts count

	        Relationship.create(person1_index: person1_input, person2_index: person2_input, 
	          created_by: created_by_input, approved_by: approved_by_input, approved_on: approved_on_input,
	          original_certainty: original_certainty_input, max_certainty: max_certainty_input,
	          edge_birthdate_certainty: edge_birthdate_certainty_in)
	       }
	     }
	     puts count
	    inFile.close
	    puts "Finished adding relationships 80001_100000"
	end
end