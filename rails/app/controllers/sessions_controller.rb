class SessionsController < ApplicationController
	def new
   
    @last_page = params[:prev]
  end
  
  def create

    user = User.authenticate(params[:email], params[:password])
    if user
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token 
      else  
        cookies[:auth_token] = user.auth_token  
      end  
      flash[:success] = "Logged in!"
      redirect_to session[:previous_url]  #This redirects to nil?
      cookies[:skiplanding] = "yes"  
    else
      flash[:alert] = "Invalid email or password"
      redirect_to sign_in_path
    end
  end

  def destroy
    session[:user_id] = nil
    cookies.delete(:auth_token) 
    flash[:error] = "Logged out!"
    redirect_to params[:prev]
  end
end

# <li><%= link_to "Sign Out", sign_out_path(prev: (root_url << controller_name << "/" << action_name)).chomp("index") %></li>
# <li><%= link_to "Sign In / Sign Up", sign_in_path(prev: (root_url << controller_name << "/" << action_name)).chomp("index") %></li>