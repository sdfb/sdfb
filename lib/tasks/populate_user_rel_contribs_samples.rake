namespace :db do
  # creating a rake task within db namespace called 'populate_user_rel_contribs_samples'
  # executing 'rake db:populate_user_rel_contribs_samples' will cause this script to run
  task :populate_user_rel_contribs_samples => :environment do 
    puts "Adding user relationship contribution samples..."
    inFile = File.new("lib/data/user_rel_contrib_samples2.tsv",'r')
    count = 0
    puts inFile
    inFile.each { |line|
      data = line.split('\n')
      data.each { |user_rel_contrib|
        userRelContribData = user_rel_contrib.split("\t")
        relationship_id_input = Relationship.for_2_people(userRelContribData[0].to_i, userRelContribData[1].to_i).first.id
        relationship_type_input = userRelContribData[2].to_i
        start_day_input = userRelContribData[3].to_i
        start_month_input = userRelContribData[4]
        start_year_input = userRelContribData[5].to_i
        end_day_input = userRelContribData[6].to_i
        end_month_input = userRelContribData[7]
        end_year_input = userRelContribData[8].to_i
        annotation_input  = userRelContribData[9]
        certainty_input = userRelContribData[10]
        created_by_input = 2
        approved_by_input = 2
        approved_on_input = Time.now
        count += 1

        a_user_rel_contrib = UserRelContrib.new do |urc| 
          urc.relationship_id = relationship_id_input
          urc.relationship_type_id = relationship_type_input
          urc.start_day = start_day_input
          urc.start_month = start_month_input
          urc.start_year = start_year_input
          urc.end_day = end_day_input
          urc.end_month = end_month_input
          urc.end_year = end_year_input
          urc.start_date_type = "IN"
          urc.end_date_type = "IN"
          urc.annotation = annotation_input
          urc.certainty = certainty_input
          urc.is_approved = true
          urc.created_by = created_by_input
          urc.approved_by = approved_by_input
          urc.approved_on = approved_on_input
          urc.save!
        end
        puts count
       }
     }
     puts count
    inFile.close
    puts "Finished adding user relationship contribution samples"
  end
end