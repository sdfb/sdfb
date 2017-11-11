class SessionsController < ApplicationController
	skip_before_action :verify_authenticity_token

  def create
    user = User.authenticate(params[:email], params[:password])

    if user
      if user.user_type == "Standard" && user.points >= 100
        user.update_attribute(:user_type, "Curator") 
      end

      respond_to do |format|   
        format.json { render json: user.as_json(minimal: true), status: :created }
      end
    else
      respond_to do |format|   
        format.json { render json: {}, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if current_user
      current_user.update_attribute(:auth_token, nil)
      @current_user = nil
    end
    respond_to do |format|   
      format.json { render json: {}, status: :ok }
    end
  end
end