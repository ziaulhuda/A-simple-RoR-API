require 'acceptance_helper'

resource "Users" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"
  
  let!(:user){create(:user, role: "admin")}
  let!(:users){create_list(:user, 4)}
  before{header "Authorization", user.auth_token}
  
  explanation "API to handel User resource. Authorization required."
    
  get "/users" do
    response_field :id, "ID of the user", "Type" => "Number"
    response_field :name, "Name of the user", "Type" => "String"
    response_field :email, "Email of the user", "Type" => "String"
    response_field :role, "Role of the user (Only if the logged in user is admin)", "Type" => "String"
    response_field :disabled, "Has user been disabled (Only if the logged in user is admin)", "Type" => "Boolean"
    
    example_request "Getting a list of users" do
      users[2].update(role: "user")
      users[0].update(role: "user")
      expect(json.size).to eq(5)
      expect(status).to eq(200)
    end
  end
  
  get "/users/:id" do
      let(:id) { users[3].id }
      
      response_field :id, "ID of the user", "Type" => "Number"
      response_field :name, "Name of order", "Type" => "String"
      response_field :email, "Email of the user", "Type" => "String"
      response_field :role, "Role of the user (Only if the logged in user is admin)", "Type" => "String"
      response_field :disabled, "Has user been disabled (Only if the logged in user is admin)", "Type" => "Boolean"

      example_request "Getting a specific user" do
        expect(json['id']).to eq(users[3].id)
        expect(status).to eq(200)
      end
    end
    
    post "/users" do
      with_options :required => true do
        parameter :name, "Name of the user"
        parameter :email, "Email of the user"
        parameter :password, "Password of the user"
      end
      parameter :role, "user role [\"admin\", \"user\", \"guest\"(default)]. Only admin can provide"
      parameter :disabled, "Is the user disabled from logging in? Only admin can provide"
      
      response_field :id, "ID of the user", "Type" => "Number"
      response_field :name, "Name of order", "Type" => "String"
      response_field :email, "Email of the user", "Type" => "String"
      response_field :role, "Role of the user (Only if the logged in user is admin)", "Type" => "String"
      response_field :disabled, "Has user been disabled (Only if the logged in user is admin)", "Type" => "Boolean"
      
      let(:name) { "Martin Craigs" }
      let(:password) { "12345678" }
      let(:email) { "email@example.com" }

      let(:raw_post) { params.to_json }

      example_request "Creating a user" do
        explanation "Admin user can create all types of users. \"user\" type users can only create \"guest\" type users. Guest users cannot create a user."

        expect(json['name']).to eq(name)
        expect(status).to eq(201)

      end
    end
    
    put "/users/:id" do
      let(:id){user.id}
      with_options :required => false do
        parameter :name, "Name of the user"
        parameter :email, "Email of the user"
        parameter :password, "Password of the user"
        parameter :role, "user role [\"admin\", \"user\", \"guest\"(default)]. Only admin can provide."
        parameter :disabled, "Is the user disabled from logging in? Only admin can provide."
      end
      
      let(:name) { "Greate King" }
      let(:raw_post) { params.to_json }

      example_request "Updating a user" do
        explanation "Admin can update all other users. \"user\" and guest type users can only update their own records."

        expect(response_body).to be_empty
        expect(status).to eq(204)

      end
    end
    
    delete "/users/:id" do
      let(:user){users[3]}
      let(:id){user.id}
      
      example_request "Deleting a user" do
        explanation "Admin can delete all other users. \"user\" and guest type users can only delete their own records."

        expect(response_body).to be_empty
        expect(status).to eq(204)

      end
    end
end