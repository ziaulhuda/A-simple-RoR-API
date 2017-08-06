#function to hadle json response
module Response
  def json_response(object, status = :ok)
    render json: object, status: status
  end
end