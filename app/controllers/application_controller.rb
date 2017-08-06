class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler
  
  before_action :is_valid_token!
  before_action :is_admin_or_user!
  
  protected
  
  def is_admin_or_user!
    return true if @current_user.admin? || @current_user.user?
    raise(ExceptionHandler::Forbidden)
  end
  
  def is_valid_token!
    if request.headers.present? && request.headers['Authorization'].present?
      auth_token = request.headers['Authorization'].split(' ').last
      begin
        @current_user = User.find_by!(auth_token: auth_token, disabled: false)
        return true
        # handle user not found
      rescue ActiveRecord::RecordNotFound => e
          # raise custom error
        raise(ExceptionHandler::InvalidToken, "Invalid token: #{e.message}")
      end
    end
    raise(ExceptionHandler::MissingToken, "Authentication token missing")
    
  end
end
