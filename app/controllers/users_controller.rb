class UsersController < ApplicationController
  skip_before_action :is_admin_or_user!, only: [:show, :index, :destroy, :update]
  
  def index
    if @current_user.admin?
      @users = User.select("id, name, email, role, disabled")
    else
      @users = User.select("id, name, email").where(disabled: false)
    end
    json_response(@users)
  end
  
  def create
    if @current_user.admin?
      @user = User.create!(user_params)
    elsif params[:role].present? && params[:role] == "guest"
      #'user' type can only create new guests
      @user = User.create!(user_params)
    else
      raise ExceptionHandler::Forbidden
    end
    json_response(@user, :created)
  end
  
  def show
    if @current_user.admin?
      @user = User.select("id, name, email, role, disabled").find(params[:id])
    else
      @user = User.select("id, name, email").where(disabled: false).find(params[:id])
    end
    json_response(@user)
  end
  
  def update
    if @current_user.id == params[:id].to_i
      @current_user.update!(user_params)
    elsif @current_user.admin?
      User.find(params[:id]).update!(user_params)
    else
      raise ExceptionHandler::Forbidden
    end
    head :no_content
  end
  
  def destroy
    #Atleast there should be 1 admin. Id 1 is supposed to be super admin
    raise ExceptionHandler::Forbidden if params[:id].to_i == 1

    if @current_user.id == params[:id].to_i
      @current_user.update!(disabled: true)
    elsif @current_user.admin?
      User.find(params[:id]).update!(disabled: true)
    else
      raise ExceptionHandler::Forbidden
    end
    head :no_content
  end
  
  private
  
  def user_params
    if @current_user.admin?
      params.permit(:name, :email, :password, :role, :disabled)
    else
      params.permit(:name, :email, :password)
    end
  end
end
