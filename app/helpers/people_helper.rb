module PeopleHelper
	# This method updates summary information related to relationship
  def update_rels(person1_index, person2_index, average_certainty, is_approved)
    # For person1, find the existing rel_sum record and update it
    person1_current_rel_sum = Person.find(person1_index).rel_sum
    # person1_new_rel_sum = []
    # person1_current_rel_sum.each do |rel_record|
    #   if rel_record[0] = person2_index
    #     rel_array = []
    #     rel_array.push(person2_index, max_certainty, is_approved)
    #   else
    #     person1_new_rel_sum.push(rel_record)
    #   end
    # end
    # check if exists first, or else create it.
    person1_updated_flag = false

    #no is_approved so this is broken!
    person1_current_rel_sum.each do |rel_record_1|
      if rel_record_1[0] == person2_index
        rel_record_1[1] = max_certainty
        rel_record_1[2] = is_approved
        rel_record_1.save!
        person1_updated_flag = true
      end
    end

    if person1_updated_flag == false
    	new_rel_record = []
    	new_rel_record.push(person2_index)
    	new_rel_record.push(max_certainty)
    	new_rel_record.push(is_approved)
    	person1_current_rel_sum.push(person2_index, max_certainty, is_approved)
    end

	person2_updated_flag = false
    # For person2, find the existing rel_sum record and update it
    person2_current_rel_sum = Person.find(person2_index).rel_sum
    # person2_new_rel_sum = []
    # person2_current_rel_sum.each do |rel_record|
    #   if rel_record[0] = person1_index
    #     rel_array = []
    #     rel_array.push(person1_index, max_certainty, is_approved)
    #   else
    #     person2_new_rel_sum.push(rel_record)
    #   end
    # end
    person2_current_rel_sum.each do |rel_record_2|
      if rel_record_2[0] == person1_index
        rel_record_2[1] = max_certainty
        rel_record_2[2] = is_approved
        rel_record_1.save!
        person2_updated_flag = true
      end
    end
  end

  # This method create summary information related to relationship
  def create_rels(person1_index, person2_index, average_certainty, is_approved)
    # For person1, find the existing rel_sum record and add the new record
    person1_current_rel_sum = Person.find(person1_index).rel_sum
    rel_array = []
    rel_array.push(person1_index, max_certainty, is_approved)
    person1_current_rel_sum.push(rel_array)
  end
end
