namespace :db do
  # creating a rake task within db namespace called 'populate_rel_unlikely'
  # executing 'rake db:populate_rel_unlikely' will cause this script to run
  task :populate_groups => :environment do
    # Read in unlikely relationships    
    puts "Adding groups..."
    inFile = File.new("lib/data/groups.csv",'r')
    count = 0
    puts inFile
    inFile.each { |line|
      data = line.split('\n')
      data.each { |group|
        groupData = group.split(",")
        name_input = groupData[1]
        description_input = '-'
        count += 1
        Group.create(name: name_input, description: description_input, is_approved: true)
        puts count
       }
     }
     puts count
    inFile.close
    puts "Finished adding groups"
  end
end