require 'acceptance_helper'

resource "Authorization" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"
  
  let!(:user){create(:user, role: "admin")}
  
  explanation "Authorization service"
    
    post "/signin" do
      with_options :required => true do
        parameter :email, "Email of the user"
        parameter :password, "Password of the user"
      end
      
      response_field :id, "ID of the user", "Type" => "Number"
      response_field :auth_token, "Authorization token to be sent in request headers for using other API actions", "Type" => "String"
      response_field :name, "Name of the user", "Type" => "String"
      response_field :role, "Role of the user. One of [admin, user, guest]", "Type" => "String"
      
      let(:password) { "12345678" }
      let(:email) { user.email }

      let(:raw_post) { params.to_json }

      example_request "Logging in" do

        expect(json['auth_token']).to eq(user.auth_token)
        expect(status).to eq(201)

      end
    end
    
    delete "/signout/:id" do
      before{header "Authorization", user.auth_token}
      let(:id){user.id}
      
      example_request "Signing out" do
        
        expect(response_body).to be_empty
        expect(status).to eq(204)

      end
    end
end