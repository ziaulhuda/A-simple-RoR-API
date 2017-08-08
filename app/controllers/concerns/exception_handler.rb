#Handle exceptions during a request and send appropriate json response with message
module ExceptionHandler
  # provides the more graceful `included` method
  extend ActiveSupport::Concern
  
  # Define custom error subclasses - rescue catches `StandardErrors`
  class AuthenticationError < StandardError; end
  class MissingToken < StandardError; end
  class InvalidToken < StandardError; end
  class Forbidden < StandardError; end

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :four_twenty_two
    rescue_from ExceptionHandler::MissingToken, with: :four_twenty_two
    rescue_from ExceptionHandler::InvalidToken, with: :four_twenty_two
    rescue_from ActiveRecord::StatementInvalid, with: :four_hundred
    
    rescue_from ExceptionHandler::Forbidden do|e|
      json_response( {error: "Action forbidden"}, :forbidden)
    end
    
    rescue_from ExceptionHandler::AuthenticationError do|e|
      json_response( {error: e.message}, :unauthorized)
    end
    
    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({ error: e.message }, :not_found)
    end
    
    private
    
    def four_hundred(e)
      json_response({ error: "Invalid parameters" }, 400)
    end
    
    def four_twenty_two(e)
      json_response({ error: e.message }, :unprocessable_entity)
    end
  end
end