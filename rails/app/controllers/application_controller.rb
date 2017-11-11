class ApplicationController < ActionController::Base
  	protect_from_forgery with: :exception
  	before_filter :expire_hsts, :allow_iframe_requests
	
	#origin/master
	private

	def expire_hsts
    	response.headers["Strict-Transport-Security"] = 'max-age=0'
  end

	def allow_iframe_requests
	  response.headers.delete('X-Frame-Options')
	end

	def current_user
		token = params[:auth_token]
		@current_user ||= User.find_by_auth_token(token) if token
		@current_user 
	end
	helper_method :current_user

end
