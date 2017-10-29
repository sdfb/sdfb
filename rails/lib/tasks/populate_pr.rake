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

      puts "Attempting to drop old tables"
      directory=`pwd`.gsub("\n","")
      #process=`PGPASSWORD=NovumOrganum1620 psql sixdfbor_sdfb -U sixdfbor_admin -c 'drop table if exists people cascade'`
      #if (! process.include?("DROP") ) 
#	puts "Failed to drop table people " +process
#      end

      process=`PGPASSWORD=NovumOrganum1620 psql sixdfbor_sdfb -U sixdfbor_admin -c 'drop table if exists relationships cascade'`
      if (! process.include?("DROP") ) 
	puts "Failed to	drop table Relationships " +process
      end
      sql_prefix="\'#{directory}/db/sql"

      puts sql_prefix+"sql_prefix"

      process = `PGPASSWORD=NovumOrganum1620 psql sixdfbor_sdfb -U sixdfbor_admin -f #{sql_prefix}/schema.sql'`
      puts "Running schema import "
      puts process

      #process = `PGPASSWORD=NovumOrganum1620 psql sixdfbor_sdfb -U sixdfbor_admin -f #{sql_prefix}/people_gen_data.sql'`
      #puts "Running people import "
      #puts process

      process =`PGPASSWORD=NovumOrganum1620 psql sixdfbor_sdfb -U sixdfbor_admin -f #{sql_prefix}/relationship_data.sql'`
      puts "Running relationship import "
      puts process

    else
      # `psql -c 'drop database sixdfbor_sdfb' & psql -c 'create database sixdfbor_sdfb'`
      # `psql -c 'create database sixdfbor_sdfb'`
      `psql sixdfbor_sdfb -c 'drop schema public cascade'`
      `psql sixdfbor_sdfb -c 'create schema public'`
      system "psql sixdfbor_sdfb -f db/sql/schema.sql"
      # system "psql sixdfbor_sdfb -f db/sql/people_gen_data.sql"
      system "psql sixdfbor_sdfb -f db/sql/relationship_data.sql"
    end

    admin = User.new
    admin.first_name = "Katarina"
    admin.last_name = "Shaw"
    admin.email = "admin@example.com"
    admin.password = "admin@FrancisBacon1"
    admin.password_confirmation = "admin@FrancisBacon1"
    admin.user_type = "Admin"
    admin.is_active = true
    admin.username = "KatAdmin"
    admin.save!

    odnb_admin = User.new
    odnb_admin.first_name = "ODNB"
    odnb_admin.last_name = "Admin"
    odnb_admin.email = "odnbadmin@example.com"
    odnb_admin.password = "admin@FrancisBacon1"
    odnb_admin.password_confirmation = "admin@FrancisBacon1"
    odnb_admin.user_type = "Admin"
    odnb_admin.is_active = true
    odnb_admin.username = "ODNB_Admin"
    odnb_admin.save!

    sdfb_admin = User.new
    sdfb_admin.first_name = "SDFB"
    sdfb_admin.last_name = "Admin"
    sdfb_admin.email = "sdfbadmin@example.com"
    sdfb_admin.password = "admin@FrancisBacon1"
    sdfb_admin.password_confirmation = "admin@FrancisBacon1"
    sdfb_admin.user_type = "Admin"
    sdfb_admin.is_active = true
    sdfb_admin.username = "SDFB_Admin"
    sdfb_admin.save!

    puts admin
    puts odnb_admin
    puts sdfb_admin

    if(! admin.valid? ) 
	puts "Invalid"
    end

    
  end
end
