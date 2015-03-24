namespace :db do
  # creating a rake task within db namespace called 'populate_rel_cats'
  # executing 'rake db:populate_rel_cats' will cause this script to run
  task :populate_rel_cats => :environment do 
    puts "Adding relationship categories..."
    inFile = File.new("lib/data/rel_categories.tsv",'r')
    count = 0
    puts inFile
    inFile.each { |line|
      data = line.split('\n')
      data.each { |relCat|
        relCatData = relCat.split("\t")
        id_input = relCatData[0]
        name_input = relCatData[1]
        created_by_input = User.for_email("sdfb_admin@example.com")[0].id
        approved_by_input = User.for_email("sdfb_admin@example.com")[0].id
        approved_on_input = Time.now
        count += 1

        a_rel_cat = RelationshipCategory.new do |rc| 
          rc.id = id_input
          rc.name = name_input
          rc.is_approved = true
          rc.created_by = created_by_input
          rc.approved_by = approved_by_input
          rc.approved_on = approved_on_input
          rc.save!
        end
        puts name_input
        puts count
       }
     }
     puts count
    inFile.close
    puts "Finished adding relationship categories"
  end
end