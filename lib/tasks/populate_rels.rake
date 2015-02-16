namespace :db do
  task :populate_rels => :environment do
    uid = 2
    prefix = "lib/data/"

    write_file="db/sql/relationship_data.sql"
    outFile = File.open(write_file,'w')
    outFile << "COPY relationships (id, from_id, to_id, created_by, approved_by, is_approved, approved_on, 
max_certainty, original_certainty, edge_birthdate_certainty) FROM stdin;\n"
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
          rec = { id: (next_id+=1), from_id: relData[0].to_i+1000000, to_id: relData[1].to_i+10000000, 
created_by: uid, approved_by: uid, is_approved: true, approved_on: current_time, max_certainty: 
(relData[2].to_f*100.00).to_i, original_certainty: (relData[2].to_f*100.00).to_i, edge_birthdate_certainty: 
(relData[3].to_f*100.00).to_i }
          outFile << 
"#{rec[:id]}\t#{rec[:from_id]}\t#{rec[:to_id]}\t#{rec[:created_by]}\t#{rec[:approved_by]}\t#{rec[:is_approved]}\t#{rec[:approved_on]}\t#{rec[:max_certainty]}\t#{rec[:original_certainty]}\t#{rec[:edge_birthdate_certainty]}\n"
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
  end
end
