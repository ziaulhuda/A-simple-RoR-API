module RequestSpecHelper
  # Parse JSON response to ruby hash
  def json
    JSON.parse(response.body)
  end
  
  # get Authorization token
  def authorization_token
    return request.headers['Authorization'].split(' ').last if response.headers['Authorization'].present? 
    nil
  end
  
  # return valid headers
   def valid_headers
     {
       "Authorization" => user.auth_token,
       "Content-Type" => "application/json"
     }
   end

   # return invalid headers
   def invalid_headers
     {
       "Authorization" => "crazyone",
       "Content-Type" => "application/json"
     }
   end
end