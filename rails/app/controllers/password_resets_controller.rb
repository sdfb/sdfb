class PasswordResetsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create  
    user = User.find_by_email(params[:email])  
    user.send_password_reset if user  
    respond_to do |format|   
      format.json { render json: {}, status: :ok }
    end
  end

  def update  
    user = User.find_by_password_reset_token!(params[:reset_token])  
    return head(:bad_request) unless params[:reset_token] && params[:password] && params[:password_confirmation]
    record = {
      password: params[:password], 
      password_confirmation: params[:password_confirmation],
    }
    if user && user.password_reset_sent_at > 2.hours.ago
      user.password = params[:password]
      user.password_confirmation = params[:password_confirmation]
      user.save!
      respond_to do |format|   
        format.json { render json: user.as_json }
     end 
    else
      return head(:forbidden)
    end  
  end  
end
