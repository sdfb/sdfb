class SessionsController < ApplicationController
	def new
  end
  
  def create
    user = User.authenticate(params[:email], params[:password])
    if user
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token 
      # redirect_to root_url, :notice => "Logged in!"
      else  
        cookies[:auth_token] = user.auth_token  
      end  
      redirect_to root_url
      cookies[:skiplanding] = "yes"  
    else
      flash.now.alert = "Invalid email or password"
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    cookies.delete(:auth_token)  
    # redirect_to root_url, :notice => "Logged out!"
    redirect_to root_url
  end
end