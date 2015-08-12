class LargeDataController < ApplicationController

	def index #will show all of what you added but I'm pretty sure there is already a page for that in user accounts
		@SomethingHere = LargeData.order("position ASC") #change how you're sorting with a scope
		#redirect_to(:controller =>'another_controller', :action => 'something in that controller')		
	end

	def show 
		#render :text => params.inspect
		@data_file = LargeData.find(params[:data_id]) 
		@duplicates = @data_file.display_duplicates_in_db
		@duplicates = @data_file.modify_duplicates(@duplicates,params) if @duplicates.nil? || @duplicates.empty?
		@data_file.merge_and_remove_duplicates(@duplicates) if @duplicates.nil? || @duplicates.empty?
		@data_file.populate_new
	end

	def new 
		#commented out for testing but it works
		#redirect_to :controller => 'sessions', :action => 'new' if (current_user.user_type != "Admin" && current_user.user_type != "Curator") 
		@data_file = LargeData.new
	end

	def edit #this is where the app will check for and show you any duplications
		hash_required = user_params
		if !hash_required.has_key?("upload_data")
			redirect_to :action => :new 
		else	
			@data_file = LargeData.new(hash_required) #make sure this has a created by
			@data_file.file_path = hash_required[:upload_data].path
			@data_file.table_file_size = File.size?(@data_file.file_path)
			@data_file.created_by = session[:user_id]
			file_correct = @data_file.file_formatted_correctly
			
			if !file_correct
				redirect_to :action => :new 
			else
				@data_file.save!
				@file_arrays = CSV.read(@data_file.file_path) 
				@duplicates = @data_file.display_duplicates_in_db
				redirect_to :action => :show if @duplicates.empty?
			end
		end
		#See if you can re-encode the file properly
		#File.open(@data_file.file_path)#.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')

		#The lines below are my attempt at using carrierwave's store method. The errors I kept getting were endless. Because of this I created a move file method which when implemented will have the files organized
		#uploader = LargeUploader.new #figure out how to assign 
		#the file path from this
		#puts hash_required[:upload_data]
		#APPARENTLY IT IS NOT THE RIGHT KIND OF FILE TO BE STORED
		#uploader.store!(File.open(hash_required[:upload_data].path)) #Try giving it the people.csv file stored in the app and see what happens
		#render :text => @data_file.file_formatted_correctly.inspect
		#render :text => @data_file.display_duplicates_in_db.inspect	
	end


	private

	# Use strong_parameters for attribute whitelisting
	# Be sure to update your create() and update() controller methods.

	def user_params
 		params.require(:large_data).permit(:upload_data, :table_file_name, :table_content_type)
	end

end