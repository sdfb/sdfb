namespace :db do
  task :generate_data => :environment do
    
    ######################################### Begin Generating People

    write_file="db/sql/people_gen_data.sql"
    outFile = File.open(write_file,'w')
    outFile << "COPY people (id, odnb_id, prefix, first_name, last_name, suffix, title, gender, 
search_names_all, birth_year_type, ext_birth_year, alt_birth_year, death_year_type, ext_death_year, 
alt_death_year, historical_significance, rel_sum, is_approved, created_by, approved_by, 
approved_on,created_at,updated_at) FROM stdin;\n"

    puts "Adding People..."
    inFile = File.new("lib/data/people.tsv",'r')
    count = 0
    uid=2 #User.for_email("odnb_admin@example.com")[0].id
    cur_time=Time.now

    inFile.each { |line|
      data = line.split('\n')

      data.each { |person|
        personData = person.split("\t")
        rel_sum_input = nil

        outFile << "#{personData[0].to_i+1000000}\t#{(personData[2] != "NA") ? personData[2].to_i : 0 
}\t#{personData[3]}\t#{personData[4]}\t#{ personData[5]}\t#{ personData[6]}\t#{ 
personData[7]}\t#{"unknown"}\t#{ personData[9] 
}\t#{personData[19]}\t#{personData[20]}\t#{personData[21]}\t#{personData[22]}\t#{personData[23]}\t#{personData[24]}\t#{personData[26]}\t#{nil}\t#{true}\t#{uid}\t#{uid}\t#{cur_time}\t#{cur_time}\t#{cur_time}\n"

       }

    }

    inFile.close
    outFile << "\\.\n"
    outFile.close
    puts "Finished adding People"


    ######################################### End Generating People

    ######################################### Begin Generating Rels


    uid = 2
    prefix = "lib/data/"

    write_file="db/sql/relationship_data.sql"
    outFile = File.open(write_file,'w')
    outFile << "truncate table relationships;\n"

    outFile << "COPY relationships (id, person1_index, person2_index, created_by, approved_by, 
is_approved, approved_on, max_certainty, original_certainty, edge_birthdate_certainty, 
created_at,updated_at) FROM stdin;\n"
    files = [ "Relationships2-20000.tsv",
              "Relationships20001-40000.tsv",
              "Relationships40001-60000.tsv",
              "Relationships60001-80000.tsv",
              "Relationships80001-100000.tsv",
              "Relationships100001-120000.tsv",
              "Relationships120001-140000.tsv",
              "Relationships140001-160000.tsv",
              "Relationships160001-170542.tsv" ]
    next_id = 1
    current_time=Time.now

    files.each { |current_file_name|
      puts "Adding relationships 100001_120000..."
      inFile = File.new(prefix+current_file_name,'r')
      rels=[]
      #start the id  set manually
      

      puts inFile
      inFile.each { |line|
        data = line.split('\n')   


        data.each { |relationship|
          relData = relationship.split("\t")
          rec = { id: (next_id+=1), from_id: relData[0].to_i+1000000, to_id: relData[1].to_i+1000000,created_by: uid, approved_by: uid, is_approved: true, approved_on: current_time, max_certainty:(relData[2].to_f*100.00).to_i, original_certainty: (relData[2].to_f*100.00).to_i, edge_birthdate_certainty: (relData[3].to_f*100.00).to_i }
          outFile << "#{rec[:id]}\t#{rec[:from_id]}\t#{rec[:to_id]}\t#{rec[:created_by]}\t#{rec[:approved_by]}\t#{rec[:is_approved]}\t#{rec[:approved_on]}\t#{rec[:max_certainty]}\t#{rec[:original_certainty]}\t#{rec[:edge_birthdate_certainty]}\t#{current_time}\t#{current_time}\n"
          rels.push(rec)
        }
       }

       # Relationship.create(rels)

       # puts rels[0],rels[7],rels[2]
      inFile.close
      
      puts "Finished adding relationships 100001_120000"
      
    }
    outFile << "\\.\n"
    outFile.close

    ######################################### End Generating Rels

  end
end
