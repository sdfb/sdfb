namespace :db do
  task :populate_pr => :environment do
    ######################################### This requires the database "sixdfbor_sdfb" to be created
    ######################################### Run "rake db:migrate" before this
    ######################################### Run "rake db:generate_data" if necessary


    files = `ls db/sql/`
    puts files
    if (!files.include?("schema.sql")) 
      puts "You need to run the population script first schema.sql missing"
    elsif (!files.include?("people_gen_data.sql")) 
      puts "You need to run the population script first people_gen_data.sql missing"
    elsif (!files.include?("relationship_data.sql")) 
      puts "You need to run the population script first relationship_data.sql missing"
    elsif `echo $USER`.include?("sixdfbor")
      #`PGPASSWORD=NovumOrganum1620 psql -d sixdfbor_sdfb -c 'drop schema public cascade' -U sixdfbor_admin`
      #`PGPASSWORD=NovumOrganum1620 psql -d sixdfbor_sdfb -c 'create schema public' -U sixdfbor_admin`

      system "PGPASSWORD=NovumOrganum1620 psql sixdfbor_sdfb -U sixdfbor_admin -f db/sql/schema.sql"
      system "PGPASSWORD=NovumOrganum1620 psql sixdfbor_sdfb -U sixdfbor_admin -f db/sql/people_gen_data.sql"
      system "PGPASSWORD=NovumOrganum1620 psql sixdfbor_sdfb -U sixdfbor_admin -f db/sql/relationship_data.sql"
    else
      # `psql -c 'drop database sixdfbor_sdfb' & psql -c 'create database sixdfbor_sdfb'`
      # `psql -c 'create database sixdfbor_sdfb'`
      `psql sixdfbor_sdfb -c 'drop schema public cascade'`
      `psql sixdfbor_sdfb -c 'create schema public'`
      system "psql sixdfbor_sdfb -f db/sql/schema.sql"
      system "psql sixdfbor_sdfb -f db/sql/people_gen_data.sql"
      system "psql sixdfbor_sdfb -f db/sql/relationship_data.sql"
    end
    
  end
end
