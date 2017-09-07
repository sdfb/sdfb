class LargeDataController < ApplicationController

	def index #will show all of what you added but I'm pretty sure there is already a page for that in user accounts
		@SomethingHere = LargeData.order("position ASC") #change how you're sorting with a scope
		#redirect_to(:controller =>'another_controller', :action => 'something in that controller')		
	end

	def new 
		if (current_user == false) 
			redirect_to :controller => 'sessions', :action => 'new' 
		else
			if (current_user.user_type != "Admin" )#&& current_user.user_type != "Curator")	
				render "error.html.erb" 
			else
				@data_file = LargeData.new
				if params.has_key?(:error_string)
					@errors = params[:error_string]
					flash[:alert] = "Your file has the following errors: " << @errors
				else
					@errors = nil
				end
			end
		end
	end

	def confirm_people 
		hash_required = user_params
		if !hash_required.has_key?("upload_data") || user_params[:upload_data].content_type != "text/csv"
			flash[:alert] = "Please submit a valid CSV file. " 
			redirect_to :action => :new 
		else	
			@data_file = LargeData.new(hash_required) #make sure this has a created by
			@data_file.file_path = hash_required[:upload_data].path
			@data_file.table_file_size = File.size?(@data_file.file_path)
			@data_file.created_by = current_user.id
			errors = @data_file.file_formatted_correctly
			
			if !errors.blank?
				redirect_to :action => :new , :error_string => errors
			else
				@data_file.file_path = @data_file.store
				@data_file.save!	
				if @data_file.table_content_type == "Person"
					redirect_to :action => :edit, :id => @data_file.id
				else
					@file_arrays = CSV.read(@data_file.file_path)
					@match_hash = @data_file.potential_person_matches 
					if @data_file.empty_matches?(@match_hash, @file_arrays) 
						redirect_to :action => :edit, :id => @data_file.id
					end
				end	
			end
		end
	end

	def edit 		
		@data_file = LargeData.find(params[:id])
		@file_arrays = CSV.read(@data_file.file_path) 
		params.delete :id
		@old_params = params
		@duplicates = @data_file.display_duplicates_in_db(params)
		redirect_to :action => :show , :data_id => @data_file.id, :people => params if @data_file.empty_duplicates?(@duplicates)
	end

	def show 	
		@data_file = LargeData.find(params[:data_id]) 
		
		@duplicates = @data_file.display_duplicates_in_db(eval(params[:people].to_s))
		
		@duplicates = @data_file.modify_duplicates(@duplicates,params) if !(@duplicates.nil? ||  @data_file.empty_duplicates?(@duplicates))
		@added_model_objects = {} #hash of row numbers added mapped to their respective models in the db
		@added_model_objects = @data_file.merge_and_remove_duplicates(@duplicates, @added_model_objects, eval(params[:people].to_s)) if !(@duplicates.nil? || @data_file.empty_duplicates?(@duplicates))		
		
		@added_model_objects = @data_file.populate_new(@added_model_objects, eval(params[:people].to_s))
		#render :text => @added_model_objects.to_yaml
	end

	def download_csv
		if params[:type] == "Person"
			send_file(
			    "#{Rails.root}/public/person_practice.csv",
			    filename: "person_practice.csv",
			    type: "text/csv"
			 )
		elsif params[:type] == "Relationship"
			send_file(
			    "#{Rails.root}/public/relationship_practice.csv",
			    filename: "relationship_practice.csv",
			    type: "text/csv"
			 )
		elsif params[:type] == "Group"
			send_file(
			    "#{Rails.root}/public/group_practice.csv",
			    filename: "group_practice.csv",
			    type: "text/csv"
			)
		end
	end

	private

	# Use strong_parameters for attribute whitelisting
	# Be sure to update your create() and update() controller methods.

	def user_params
 		params.require(:large_data).permit(:upload_data, :table_file_name, :table_content_type)
	end

end