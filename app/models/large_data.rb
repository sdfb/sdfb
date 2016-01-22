class LargeData < ActiveRecord::Base
	
	self.table_name = "large_data"

	#has_attached_file :upload_data,
	#:url => "/:attachment/:id/:style/:basename/:extension"
			#:path => ":rails_root/public/system/:id/:basename"
	#note these are the defaul url and file placements paperclip uses
	#do_not_validate_attachment_file_type :upload_data

	#***people and relationships might need justifications with a minimum of 4, can be included in meets validations funcitons

	
	attr_accessible :id, :upload_data , :table_file_name, :table_content_type, :file_path, :table_file_size, :created_by
	

	has_many :people #associates with people it contains
	has_many :relationships #associates with relationships it contained
	has_many :groups #associates with groups it contained
	belongs_to :user #associates with the user that uploaded the file	

	mount_uploader :upload_data, LargeUploader

	#Validations
	#--------------------------------------
	validates_presence_of :upload_data 
	validates_presence_of :table_content_type

	CONTENT_TYPE_LIST = ["Person", "Relationship", "Group"]
	validates_inclusion_of :table_content_type , :in => CONTENT_TYPE_LIST
	
	#Step one: Create an instance of Large DAta probably in the controller
	#Step two: call some of these helper functions on the instance
	#Step three: Check to see if the user is logged in as a curator or admin
	#Step four: if So one of the helper functions will bring up a list of all the
	#           similar relationships/people/groups to check and see if they already exist in 6dfb
	#           NOTE: this step only occurs with data that has less than 50 entries in a file (to not be cumbersome for the user)
	#Step five: In that presentation each of the relationships/people/groups that are recognized will appear as checkboxes.
	#Step six: The user will submit this info and then a helper function will enter all of the data into the database
	#Step seven: A success page will be generated listing and people/relationships/groups that could not be entered into the database
	
	# Manipulation Methods
	# -------------------------------------------------------
	
	
	def upload_data_will_change!
		#Not sure what this does but it keeps carrierwave from crashing!
	end

	def store
		original = CSV.read(self.file_path)
		filename = "public/" << Time.now.day.to_s << Time.now.month.to_s << Time.now.year.to_s << Time.now.hour.to_s << Time.now.min.to_s << Time.now.sec.to_s << ".csv"
		CSV.open(filename, "w") do |new_file|
			original.each do |row|
				new_file << row
			end
		end
		return filename
	end

	def empty_matches?(match_hash,file_arrays)
		1.upto(file_arrays.count - 1) do |row_index|
			if self.table_content_type == "Relationship"
				return false if match_hash[row_index][1].count > 1
				return false if match_hash[row_index][2].count > 1
			elsif self.table_content_type == "Group"
				return false if match_hash[row_index][:match].count > 1
			end
		end
		return true
	end

	def empty_duplicates?(duplicates)
		duplicates.each do |row_number, match_array|
			return false if match_array.class == Array && !match_array.empty?
			return false if match_array.class != Array && !match_array.nil? 
		end
		return true
	end

	def file_formatted_correctly
		#check for duplicates in the file
		#make sure the required fields are non nil
		#will return an array of error messages for each row
		#need to check that all the headings converted to symbols are in the accessible attributes list
		body_rows = CSV.read(self.file_path)
		header_row = body_rows.delete_at(0)
		date_list = ["BF", "AF","IN","CA","BF/IN","AF/IN","NA"]
		gender_list = ["female", "male", "gender_nonconforming"]
		
		#Initializes error container
		error_array = ""

		#Removes trailing whitespace from headers and fills in errors
		for heading in header_row
			heading.strip
			error_array << "At least one of your column headers are blank." if heading.blank? && !error_array.include?("At least one of your column headers are blank. ")
			if !error_array.include? "At least one of your column headers are not in the valid list of column headers. "
				error_array << "At least one of your column headers are not in the valid list of column headers. " if self.table_content_type == "Relationship" && !["first_name 1", "last_name 1", "first_name 2", "last_name 2", "original_certainty", "max_certainty", "start_year", "start_month", "start_day", "end_year", "end_month", "end_day", "start_date_type", "end_date_type", "justification"].include?(heading)
				error_array << "At least one of your column headers are not in the valid list of column headers. " if self.table_content_type == "Person" && !["first_name", "last_name", "ext_birth_year", "ext_death_year", "gender", "odnb_id", "historical_significance", "prefix", "suffix", "title", "birth_year_type", "ext_birth_year", "alt_birth_year", "death_year_type", "ext_death_year", "alt_death_year", "justification" ].include?(heading)
				error_array << "At least one of your column headers are not in the valid list of column headers. " if self.table_content_type == "Group" && !["name", "description", "first_name", "last_name", "justification", "start_year", "end_year", "start_date_type", "end_date_type"].include?(heading)
			end			
		end
		#remove trailing whitespace from the file
		body_rows.each do |row|
			row.each do |cell|
				cell.strip if !cell.nil?
			end
		end

		if (self.table_content_type == "Relationship")
			first_name_index_1 = header_row.index("first_name 1")
			first_name_index_2 = header_row.index("first_name 2")
			second_name_index_1 = header_row.index("last_name 1")
			second_name_index_2 = header_row.index("last_name 2")
			original_certainty_index = header_row.index("original_certainty")
			sdt_index = header_row.index("start_date_type")
			edt_index = header_row.index("end_date_type")

			error_array << "One of the required column headers are missing." if (first_name_index_1.nil? || second_name_index_1.nil? || first_name_index_2.nil? || second_name_index_2.nil? || original_certainty_index.nil?)
			row_index = 1
			body_rows.each do |row|
				return error_array if error_array.bytesize > 2500 
				error_array << "Row #{row_index} is missing a first name. " if !first_name_index_1.nil? && row[first_name_index_1].nil?
				error_array << "Row #{row_index} is missing a last name. " if !second_name_index_1.nil? && row[second_name_index_1].nil?
				error_array << "Row #{row_index} is missing a first name. " if !first_name_index_2.nil? && row[first_name_index_2].nil? && !error_array.include?("Row #{row_index} is missing a first name.")
				error_array << "Row #{row_index} is missing a last name. " if !second_name_index_2.nil? && row[second_name_index_2].nil? && !error_array.include?("Row #{row_index} is missing a last name.")
				error_array << "Row #{row_index} is missing a max_certainty. " if !original_certainty_index.nil? && row[original_certainty_index].nil?
				error_array << "Row #{row_index} has an invalid start date type. " if !sdt_index.nil? && !date_list.include?(row[sdt_index])
				error_array << "Row #{row_index} has an invalid end date type. " if !edt_index.nil? && !date_list.include?(row[edt_index]) 
				first_person = Person.find_by(first_name: row[first_name_index_1], last_name: row[second_name_index_1]) if !first_name_index_1.nil? && row[first_name_index_1].nil? && !second_name_index_1.nil? && row[second_name_index_1].nil?
				second_person = Person.where.not(id: first_person.id).find_by(first_name: row[first_name_index_2], last_name: row[second_name_index_2]) if !first_name_index_2.nil? && row[first_name_index_2].nil? && !second_name_index_2.nil? && row[second_name_index_2].nil?
				error_array << "One of the two people in row #{row_index} are not in the database or both people are the same in the database. " if first_person.nil? || second_person.nil?
				row_index += 1 			
			end

		elsif (self.table_content_type == "Person")
			first_name_index = header_row.index("first_name")
			last_name_index = header_row.index("last_name")
			birth_year_index = header_row.index("ext_birth_year")
			death_year_index = header_row.index("ext_death_year")
			gender_index = header_row.index("gender")
			byt_index = header_row.index("birth_year_type")
			dyt_index = header_row.index("death_year_type")
			error_array[0] << "One of the required column headers are missing. " if gender_index.nil? || first_name_index.nil? || last_name_index.nil? || birth_year_index.nil? || death_year_index.nil?
			row_index = 1
			body_rows.each do |row|
				return error_array if error_array.bytesize > 2500
				error_array << "Row #{row_index} is missing a first name. " if !first_name_index.nil?  && row[first_name_index].nil?
				error_array << "Row #{row_index} is missing a last name. " if !last_name_index.nil? && row[last_name_index].nil?
				error_array << "Row #{row_index} is missing a birth year. " if !birth_year_index.nil? && row[birth_year_index].nil?
				error_array << "Row #{row_index} is missing a death year. " if !death_year_index.nil? && row[death_year_index].nil?
				error_array << "Row #{row_index} is missing a gender. " if !gender_index.nil? && row[gender_index].nil?
				error_array << "In row #{row_index}, the gender is not a valid type. " if !gender_index.nil? && !gender_list.include?(row[gender_index]) 
				error_array << "Row #{row_index} has an invalid birth year type. " if !byt_index.nil? && !row[byt_index].nil? && !date_list.include?(row[byt_index])
				error_array << "Row #{row_index} has an invalid death year type. " if !dyt_index.nil? && !row[dyt_index].nil? && !date_list.include?(row[dyt_index]) 
				row_index += 1
			end

		elsif (self.table_content_type == "Group")
			group_name_index = header_row.index("name")
			description_index = header_row.index("description")
			first_name_index = header_row.index("first_name")
			last_name_index = header_row.index("last_name")
			sdt_index = header_row.index("start_date_type")
			edt_index = header_row.index("end_date_type")
			error_array[0] << "One of the required column headers are missing." if group_name_index.nil? || description_index.nil? || first_name_index.nil? || last_name_index.nil?
			row_index = 1
			body_rows.each do |row|
				return error_array if error_array.bytesize > 2500 
				error_array << "Row #{row_index} is missing a group name. " if  !group_name_index.nil? && row[group_name_index].nil?  
				error_array << "Row #{row_index} is missing a description. " if !description_index.nil? && row[description_index].nil?
				error_array << "Row #{row_index} is missing a first name. " if  !first_name_index.nil? && row[first_name_index].nil?
				error_array << "Row #{row_index} is missing a last name. " if !last_name_index.nil? && row[last_name_index].nil?
				error_array << "Group names must be a minimum of 3 characters. " if group_name_index.nil? && row[group_name_index].length < 3
				error_array << "Person in row #{row_index} is not in the database. " if !first_name_index.nil? && !last_name_index.nil? && Person.find_by(first_name: row[first_name_index], last_name: row[last_name_index]).nil?
				error_array << "Row #{row_index} has an invalid start_date_type. " if !sdt_index.nil? && !date_list.include?(row[sdt_index])
				error_array << "Row #{row_index} has an invalid end_date_type. " if !edt_index.nil? && !date_list.include?(row[edt_index])
				row_index += 1
			end

		else
			return "File content type wasn't selected."
		end
		return error_array
	end

	def potential_person_matches
		data_rows = CSV.read(self.file_path)
		header_row = data_rows[0]
		hash = {}
		1.upto(data_rows.count-1) do |row_index|
			if (self.table_content_type == "Relationship")
				fn_1 = header_row.index("first_name 1")
				ln_1 = header_row.index("last_name 1")
				fn_2 = header_row.index("first_name 2")
				ln_2 =header_row.index("last_name 2")
				hash[row_index] = {1 => nil, 2 => nil, :name_one => nil , :name_two => nil}
				hash[row_index][1]= Person.where(first_name: data_rows[row_index][fn_1], last_name: data_rows[row_index][ln_1]) 
				hash[row_index][2]= Person.where(first_name: data_rows[row_index][fn_2], last_name: data_rows[row_index][ln_2])
				hash[row_index][:name_one] = [data_rows[row_index][fn_1],data_rows[row_index][ln_1]]
				hash[row_index][:name_two] = [data_rows[row_index][fn_2],data_rows[row_index][ln_2]]
			elsif (self.table_content_type == "Group")
				fn = header_row.index("first_name")
				ln = header_row.index("last_name")
				group_name = header_row.index("name")
				hash[row_index] = {:match => nil, :name => nil}
				hash[row_index][:match] = Person.where(first_name: data_rows[row_index][fn], last_name: data_rows[row_index][ln])
				hash[row_index][:name] = [data_rows[row_index][fn],data_rows[row_index][ln]]
				hash[row_index][:group] = data_rows[row_index][group_name]
			end
			
		end 
		return hash
	end

	def display_duplicates_in_db(params_hash)
		#######doesn't handle the case of each of the find_by calls returning an array instead of a group
		#adding multiple of the same match
		file_path = self.file_path
		new_hash = {} 
		#Keys are the row numbers of information provided. values are an array of arrays of matching entries
		row_num = 0
		first_row = {}
		ids_added = []

		if (self.table_content_type == "Group")
			rows_checked = []
			data_rows = CSV.read(file_path)
			group_hash = {} 
			0.upto(data_rows.count-1) do |row_index| 
				if row_index == 0
					#Map Relevant Column Titles to indicies

					column_index = 0
					for heading in data_rows[0] 
						if ["name","description", "first_name", "last_name", "justification","start_year","end_year","start_date_type","end_date_type"].include?(heading)			
							first_row[heading] = column_index
						end
						column_index += 1
					end
				else
					
					if rows_checked.include?(row_index) 
						#Do Nothing
					else
						match_array = [] #array of groups similar to the one at row index
						match = Group.find_by(name: data_rows[row_index][first_row["name"]], description: data_rows[row_index][first_row["description"]])
						if !match.nil? && !ids_added.include?(match.id)
							ids_added << match.id
							match_array << match 
						end
						match = Group.find_by(name: data_rows[row_index][first_row["name"]], start_year: data_rows[row_index][first_row["start_year"]], end_year: data_rows[row_index][first_row["end_year"]])
						if !match.nil? && !ids_added.include?(match.id)
							ids_added << match.id
							match_array << match 
						end
						
						#Find Groups by similar people
						#match = Group.find_by(name: data_rows[row_index[first_row["name"]]])
						#match_array << match if !match.nil?
						#This part is supposed to add a group to potential matches if they have more than 3 of the same members
						#db_person_list = []

						# GroupAssignment.find_by(group_id: match.id).each do |relationship|
						# 	db_person_list << relationship.person_id
						# end

						# file_person_list = []

						# data_rows.each do |row|
						# 	if row[first_row["name"]] == match.name
						# 		file_person_list << Person.find_by(first_name: row[first_row["first_name"]], last_name: row[first_row["last_name"]]).id
						# 		rows_checked << row_num
						# 	end
						# end
						# match_array << match if ((Set.new(db_person_list) & Set.new(file_person_list)).length > 3)

						new_hash[row_index] = match_array if !match_array.empty?#still maps matches to first rownumber with that group name
					end
				end
			end
		else
			CSV.read(file_path).each do |row| 
				#Reads from arrays instead of leaving the file itself open

				if row_num == 0

					#Map Relevant Column Titles to indicies

					column_index = 0
					for heading in row 
					
						if ["odnb_id", "display_name", "first_name", "last_name","first_name 1", "last_name 1","first_name 2", "last_name 2"].include?(heading)			
							first_row[heading] = column_index
						end
						column_index += 1
					end
					is_first_row = false
				
				else
				
					#Start adding related database entries to the new_hash for each data row in the file

					if (self.table_content_type == "Person")
						new_hash[row_num] = []

						if first_row.has_key?("odnb_id") #Absolute match
							val = Person.where(odnb_id: row[first_row["odnb_id"]].to_i) 
							
							if !val.nil?
								val.each do |ar_relation_obj| 
									if !ids_added.include?(ar_relation_obj.id ) 
										new_hash[row_num].push(Person.find_by(id: ar_relation_obj.id))
										ids_added << ar_relation_obj.id 
									end
								end
							end 
							#########break
						end

						if first_row.has_key?("first_name") && first_row.has_key?("last_name")
							val = Person.where(first_name: row[first_row["first_name"]].capitalize  , last_name: row[first_row["last_name"]].capitalize) 
							if !val.nil? 
								val.each do |ar_relation_obj| 
									if !ids_added.include?(ar_relation_obj.id ) 
										new_hash[row_num].push(Person.find_by(id: ar_relation_obj.id))
										ids_added << ar_relation_obj.id 
									end
								end
							end 
						end

						if first_row.has_key?("display_name")
							val = Person.find_by(display_name: row[first_row["display_name"]])
							if !val.nil? 
								val.each do |ar_relation_obj| 
									if !ids_added.include?(ar_relation_obj.id ) 
										new_hash[row_num].push(Person.find_by(id: ar_relation_obj.id))
										ids_added << ar_relation_obj.id 
									end
								end
							end 
						end

						# if first_row.has_key?("Name") && !first_row.has_key?("display_name") && !first_row.has_key?("first_name")
						# 	val1 = Person.find_by(display_name: row[first_row["display_name"]])
						# 	val2 = Person.find_by(first_name: row[first_row["first_name"]].split.first.capitalize  , last_name: row[first_row["last_name"]].split.last.capitalize)
						# 	if !val1.nil? && !val2.nil? 
						# 		if new_hash[row_num].nil?
						# 			new_hash[row_num] = [val1, val2]
						# 		else
						# 			new_hash[row_num].push(val1)
						# 			new_hash[row_num].push(val2)
						# 		end
						# 	elsif val1.nil?
						# 		if new_hash[row_num].nil?
						# 			new_hash[row_num] = val2
						# 		else
						# 			new_hash[row_num].push(val2)
						# 		end
						# 	elsif val2.nil?
						# 		if new_hash[row_num].nil?
						# 			new_hash[row_num] = val1
						# 		else
						# 			new_hash[row_num].push(val1)
						# 		end								
						# 	else
						# 		break
						# 	end 
						# end

					elsif (self.table_content_type == "Relationship")
						#indexes are ids in the database
						new_hash[row_num] = []
						person_one = Person.find(params_hash[row_num.to_s]["1"]) 
						person_two = Person.find(params_hash[row_num.to_s]["2"])
						if person_one.nil? || person_two.nil?
						 	#######break
						else
							match = Relationship.find_by(person1_index: person_one.id, person2_index: person_two.id)
							if !match.nil? && !ids_added.include?(match.id)
								ids_added << match.id
								new_hash[row_num].push(match)
							elsif match.nil?
								match = Relationship.find_by(person1_index: person_two.id, person2_index: person_one.id)
								if !match.nil? && !ids_added.include?(match.id)
									ids_added << match.id
									new_hash[row_num].push(match) 
								end
							end
						end
					end
					
				end
			row_num += 1

			end
		end
		
		return new_hash
	end

	def modify_duplicates(merge_hash, user_input)
		#updates the duplicates hash with user edits
		user_input.keys.each do |row_number|
			merge_hash_key = row_number.to_i
			if merge_hash_key > 0 #eliminates all params keys that aren't row numbers
				if user_input[row_number]["chosen_match"] == "none"
					merge_hash.delete(merge_hash_key)
				else
					if self.table_content_type == "Person"
						merge_hash[merge_hash_key] = Person.find(user_input[row_number][:chosen_match]) 
						user_input[row_number].each do |key,value|
							if key != "chosen_match" && !key.blank? && !value.blank?
								merge_hash[merge_hash_key][key] = value
							end
						end
					elsif self.table_content_type == "Relationship"
						merge_hash[merge_hash_key] = Relationship.find(user_input[row_number][:chosen_match]) 
						user_input[row_number].each do |key,value|
							if key != "chosen_match" && !key.blank? && !value.blank?
								merge_hash[merge_hash_key][key] = value
							end
						end
					elsif self.table_content_type == "Group"
						merge_hash[merge_hash_key] = Group.find(user_input[row_number][:chosen_match]) 
						user_input[row_number].each do |key,value|
							if key != "chosen_match" && !key.blank? && !value.blank?
								merge_hash[merge_hash_key][key] = value

							end
						end
					end
				end	
			end
		end
		return merge_hash
	end

	def merge_and_remove_duplicates(merge_hash, added_model_objects, verified_people) 
		#For the merge_hash that is taken in:
		#The keys for the hash are row numberes in the file has a person/relationship/group model that has been edited with user input that will replace an existing db entry
		#it adds the matches and user edits and enters those and deletes them from the file which leaves only unmatched data in the file.
		file_path = self.file_path
		data_file = CSV.read(file_path)
		test_array = []
		merge_hash.keys.each do |row_number|
			match = merge_hash[row_number]  
			
			if (match.class == Person || match.class == Relationship)
				original = match.class.find_by(id: match.id) 
				match.attributes.each do |key,value|
					if match.class.accessible_attributes.to_a.include?(key)
						original.update_attribute(key.to_sym,value) if !value.blank?
					end
				end	
				self.meet_validations(original,self.table_content_type)
				original.save
				added_model_objects[row_number] = original
			
			#Test for groups
			elsif match.class == Group
				original = match.class.find_by(id: match.id) 
				match.attributes.each do |key,value|
					if match.class.accessible_attributes.to_a.include?(key)
						if !value.blank?
							original.update_attribute(key.to_sym,value) 
							
						end
					end
				end	
				self.meet_validations(original,self.table_content_type)
				original.save
				group_name_column = data_file[0].index("name")
				model_added = false
				
				1.upto(data_file.count - 1) do |row_index|

					if data_file[row_index][group_name_column] == match.name && !model_added
						if !GroupAssignment.exists?(group_id: original.id, person_id: verified_people[row_index.to_s])
							data = GroupAssignment.new(group_id: original.id, person_id: verified_people[row_index.to_s], created_by: self.created_by, is_approved: true, is_active: true, is_rejected: false) 
							data.save!
						end
						added_model_objects[row_number] = original
						model_added = true 

					elsif data_file[row_index][group_name_column] == match.name
						if !GroupAssignment.exists?(group_id: original.id, person_id: verified_people[row_index.to_s])
							data = GroupAssignment.new(group_id: original.id, person_id: verified_people[row_index.to_s], created_by: self.created_by, is_approved: true, is_active: true, is_rejected: false) 
							data.save!
						end
					end
				end		
				
			end
		end	
		return added_model_objects
	end

	#Having each section check added model objects
	def populate_new(added_model_objects, verified_people) #Check that this works for all content types of files
		#if a value is nil in the file the it will be the string nil. set that to the value nil before storing
		#for relationships and groups, the people in the relationships and groups need to be added before the relationships
		#Currently not working for groups
		file_path = self.file_path 
		create_function = nil
		data_object = CSV.read(file_path)
		if (self.table_content_type == "Person") 
			first_row = []
			data_object[0].each do |heading| 
				first_row.push(heading.to_sym)
			end
			data_hash= {}
			1.upto(data_object.count - 1) do |row_number|
				if !added_model_objects.keys.include?(row_number)
					row = data_object[row_number]
					0.upto(row.count) do |entry_index|
						data_hash[first_row[entry_index]] = row[entry_index] if Person.accessible_attributes.include?(first_row[entry_index])
						#creates a dictionary mapping the first row as keys that are symbols to each other row as values
					end
					data = Person.new(data_hash)
					data.created_by = self.created_by 
					self.meet_validations(data,self.table_content_type) 
					data.save!
					added_model_objects[row_number] = data
				end
			end  		

		elsif (self.table_content_type == "Relationship") 

			headers= {fn1_index: data_object[0].index("first_name 1"), fn2_index: data_object[0].index("first_name 2"), ln1_index: data_object[0].index("last_name 1"), ln2_index: data_object[0].index("last_name 2"), oc_index: data_object[0].index("original_certainty"), sy_index: data_object[0].index("start_year"), sm_index: data_object[0].index("start_month"), sd_index: data_object[0].index("start_day"), ey_index: data_object[0].index("end_year"), em_index: data_object[0].index("end_month"), ed_index: data_object[0].index("end_day"), sdt_index: data_object[0].index("start_date_type"), edt_index: data_object[0].index("end_date_type")}			
			#relationship_object = [[ person1_index, person2_index, original_certainty, start_year, start_month, start_day, end_year, end_month, end_day, start_date_type, end_date_type]]
			1.upto(data_object.count - 1) do |row_number|
				if !added_model_objects.keys.include?(row_number)
					row = data_object[row_number]
					new_hash = {}
					#:person1_index
					new_hash[:person1_index] = verified_people[row_number.to_s]["1"]
					#person2_index
					new_hash[:person2_index] = verified_people[row_number.to_s]["2"]
					#original_certainty
					new_hash[:original_certainty] = row[headers[:oc_index]]
					#start_year
					new_hash[:start_year] = row[headers[:sy_index]] if !headers[:sy_index].nil?
					#start_month
					new_hash[:start_month] = row[headers[:sm_index]] if !headers[:sm_index].nil?
					#start_day
					new_hash[:start_day] = row[headers[:sd_index]] if !headers[:sd_index].nil?
					#end_year
					new_hash[:end_year] = row[headers[:ey_index]]  if !headers[:ey_index].nil?
					#end_month
					new_hash[:end_month] = row[headers[:em_index]] if !headers[:em_index].nil?
					#end_day
					new_hash[:end_day] = row[headers[:ed_index]] if !headers[:ed_index].nil?
					#start_date_type
					new_hash[:start_date_type] = row[headers[:sdt_index]] if !headers[:sdt_index].nil?
					#end_date_type
					new_hash[:end_date_type] = row[headers[:edt_index]] if !headers[:edt_index].nil?

					data = Relationship.new(new_hash)
					data.created_by = self.created_by #put in the created_by part for person, relationship, and group
					self.meet_validations(data,self.table_content_type) #puts in data to pass the validations
					data.save!
					added_model_objects[row_number] = data
				end
			end

		elsif (self.table_content_type == "Group")

			create_function = Group.method('new')

			#group_object = [[name, description, start_year,  start_date_type, end_year, end_date_type, person_list]]

			headers= {fn_index: data_object[0].index("first_name"), ln_index: data_object[0].index( "last_name"), n_index: data_object[0].index("name"), d_index: data_object[0].index("description"), sy_index: data_object[0].index("start_year"), sdt_index: data_object[0].index("start_date_type"), ey_index: data_object[0].index("end_year"), edt_index: data_object[0].index("end_date_type")}

			people_lists={}

			1.upto(data_object.count - 1) do |row_number|
				if !added_model_objects.keys.include?(row_number)
					row = data_object[row_number]
					key = row[headers[:n_index]]
					people_lists[key] = [Person.find(verified_people[row_number.to_s])] if !people_lists.has_key?(key)
					people_lists[key].push(Person.find(verified_people[row_number.to_s]))
				end
			end

			groups_added = []
			1.upto(data_object.count - 1) do |row_number|
			row = data_object[row_number]
				if !groups_added.include?(row[headers[:n_index]])
					if !added_model_objects.keys.include?(row_number)
						new_hash = {}
						new_hash[:name] = row[headers[:n_index]]
						new_hash[:description] = row[headers[:d_index]]
						new_hash[:start_year] = row[headers[:sy_index]] if !headers[:sy_index].nil?
						new_hash[:start_date_type] = row[headers[:sdt_index]] if !headers[:sdt_index].nil? 
						new_hash[:end_year] = row[headers[:ey_index]] if !headers[:ey_index].nil?
						new_hash[:end_date_type] = row[headers[:edt_index]] if !headers[:edt_index].nil?
						new_hash[:person_list] = people_lists[row[headers[:n_index]]]
						data = Group.new(new_hash)
						data.created_by = self.created_by #put in the created_by part for person, relationship, and group
						self.meet_validations(data,self.table_content_type) #puts in data to pass the validations
						data.save!
						people_lists[row[headers[:n_index]]].each do |person|
							if !GroupAssignment.exists?(group_id: data.id, person_id: person.id)
								relation = GroupAssignment.new(group_id: data.id, person_id: person.id, created_by: self.created_by, is_approved: true, is_active: true, is_rejected: false) 
								relation.save!
							end
						end
						groups_added << new_hash[:name]
						added_model_objects[row_number] = data
					end
				end
			end
			
		else 
			#When the table content type isn't righ
		end 
		return added_model_objects   
	end

	def meet_validations(data, content_type)
		date_types = ["BF", "AF","IN","CA","BF/IN","AF/IN","NA"]
		if (content_type == "Person")
			data.birth_year_type = "IN" if data.birth_year_type == nil || data.birth_year_type == "" || !date_types.include?(data.birth_year_type)
			data.death_year_type = "IN" if data.death_year_type == nil || data.death_year_type == "" || !date_types.include?(data.death_year_type)
			data.ext_birth_year = "unknown" if data.ext_birth_year == nil || data.ext_birth_year == ""
			data.ext_death_year = "unknown" if data.ext_death_year == nil || data.ext_death_year == ""
			data.is_approved = true
			data.is_active = true
			data.is_rejected = false
			data.approved_by = self.created_by
		elsif (content_type == "Relationship") 
			
			if data.start_year.present?
				data.start_year = nil if data.start_year < 1400 
				data.start_year = nil if data.start_year > 1800
				data.start_date_type = "IN" if !data.start_year.nil? && (data.start_date_type == nil || !date_types.include?(data.start_date_type))
				data.start_date_type = nil if data.start_year.nil?
			end

			if data.end_year.present?
				data.end_year = nil if data.end_year < 1400 
				data.end_year = nil if data.end_year > 1800
				data.end_date_type = "IN" if !data.end_year.nil? && (data.end_date_type == nil || !date_types.include?(data.end_date_type))
				data.end_date_type = nil if data.end_year.nil?
			end
			data.is_approved = true
			data.is_active = true
			data.is_rejected = false
			data.approved_by = self.created_by
		
		elsif (content_type == "Group")
			
			if data.start_year.present?
				data.start_year = nil if data.start_year < 1400 
				data.start_year = nil if data.start_year > 1800
				data.start_date_type = "IN" if !data.start_year.nil? && !date_types.include?(data.start_date_type)
			end
			if data.end_year.present?
				data.end_year = nil if data.end_year < 1400 
				data.end_year = nil if data.end_year > 1800
				data.end_date_type = "IN" if !data.end_year.nil? && !date_types.include?(data.end_date_type)
			end
			data.is_approved = true
			data.is_active = true
			data.is_rejected = false
			data.is_approved = self.created_by
		end
	end
end