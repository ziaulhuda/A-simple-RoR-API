class SessionsController < ApplicationController
  skip_before_action :is_valid_token!, only: [:create]
  skip_before_action :is_admin_or_user!, only: [:create, :destroy]
  
  def create
    user = User.find_by(email: params[:email], disabled: false)
    if user && user.authenticate(params[:password])
      json_response({auth_token: user.auth_token, name: user.name, role: user.role}, :created )
    else
      raise(ExceptionHandler::AuthenticationError, "Invalid credentials")
    end
  end
  
  def destroy
    #create a new token to void all other sessions
    if @current_user.id == params[:id].to_i
      @current_user.regenerate_auth_token
      head :no_content
    else
      raise(ExceptionHandler::Forbidden)
    end
  end
  
  private
  
  def session_params
    params.permit(:email, :password)
  end
  
end
