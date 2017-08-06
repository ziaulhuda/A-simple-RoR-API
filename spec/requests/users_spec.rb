require 'rails_helper'

RSpec.describe 'Users API:', type: :request do
  
  #test data
  let!(:user_admin) {create(:user, role: "admin")}
  let!(:user_user) {create(:user, role: "user")}
  let!(:user_guest) {create(:user, role: "guest")}
  let!(:user_disabled) {create(:user, disabled: true)}
  
  describe "Geust users:" do
    let(:user){user_guest}
    context "Post /users" do
      let(:correct_params){{name: 'nice name', email: "sdf@jj.ed", password: "1234"}}
      before { post '/users', params: correct_params.to_json, headers: valid_headers}
      it "should respond with status 403" do
        expect(response).to have_http_status(403)
      end
      it "should not create user" do
        expect(User.count).to eq(4)
      end
    end
    
    context "change self Put /users/:id" do
      let(:correct_params){{name: 'asdfe'}}
      before { put "/users/#{user.id}", params: correct_params.to_json, headers: valid_headers}
      it "should update the user" do
        expect(response.body).to be_empty
        expect(User.find(user.id).name).to eq(correct_params[:name])
      end
      
      it "should respond with code 204" do
        expect(response).to have_http_status(204)
      end
    end
    
    context "change other Put /users/:id" do
      let(:correct_params){{name: 'asdfe'}}
      before { put "/users/#{user_user.id}", params: correct_params.to_json, headers: valid_headers}
      it "should not change user" do
        expect(response).to have_http_status(403)
        expect(User.find(user_user.id).name).not_to eq(correct_params[:name])
      end
    end
    
    context "Delete others /users/:id" do
      before {delete "/users/#{user_user.id}", params: {}, headers: valid_headers}
      it "should not delete user" do
        expect(User.find(user_user.id).disabled).to eq(false)
        expect(response).to have_http_status(403)
      end
    end
    
    context "Delete self /users/:id" do
      before {delete "/users/#{user.id}", params: {}, headers: valid_headers}
      it "should delete the user" do
        expect(User.find(user.id).disabled).to eq(true)
        expect(response.body).to be_empty
      end
    
      it "should respond with code 204" do
        expect(response).to have_http_status(204)
      end
    end
    
    context 'GET /users' do
      #initialize reguest
      before { get '/users', params: {}, headers: valid_headers}
    
      it "sends users" do
        #json implemented in support/request__spec_helpers
        expect(json[0]['role']).to be_nil
        expect(json[0]['disabled']).to be_nil
        expect(json.size).to eq(3) #no disabled shown
      end
    
      it "return code 200" do
        expect(response).to have_http_status(200)
      end
    end
    
    context 'GET /users/:id' do
      #initialize reguest
      before { get "/users/#{user.id}", params: {}, headers: valid_headers}
    
      it "sends user" do
        #json implemented in support/request__spec_helpers
        expect(json['role']).to be_nil
        expect(json['disabled']).to be_nil
        expect(json['id']).to eq(user.id)
      end
    
      it "return code 200" do
        expect(response).to have_http_status(200)
      end
    end
  end
  
  describe "User users:" do
    let(:user){user_user}
    context "Post /users as admin" do
      let(:correct_params){{name: 'nice name', email: "sdf@jj.ed", password: "12345678", role: "admin"}}
      before { post '/users', params: correct_params.to_json, headers: valid_headers}
      it "should respond with status 403" do
        expect(response).to have_http_status(403)
      end
      it "should not create user" do
        expect(User.count).to eq(4)
      end
      
    end
    
    context "Post /users as user" do
      let(:correct_params){{name: 'nice name', email: "sdf@jj.ed", password: "12345678", role: "user"}}
      before { post '/users', params: correct_params.to_json, headers: valid_headers}
      it "should respond with status 403" do
        expect(response).to have_http_status(403)
      end
      it "should not create user" do
        expect(User.count).to eq(4)
      end
    end
    
    context "Post /users as guest" do
      let(:correct_params){{name: 'nice name', email: "sdf@jj.ed", password: "12345678", role: "guest"}}
      before { post '/users', params: correct_params.to_json, headers: valid_headers}
      it "should create user" do
        expect(json['email']).to eq(correct_params[:email])
        expect(User.count).to eq(5)
      end
      it "should respond with code 201" do
        expect(response).to have_http_status(201)
      end
    end
    
    context "change other Put /users/:id" do
      let(:correct_params){{name: 'asdfe'}}
      before { put "/users/#{user_guest.id}", params: correct_params.to_json, headers: valid_headers}
      it "should not update user" do
        expect(response).to have_http_status(403)
        expect(User.find(user_guest.id).name).not_to eq(correct_params[:name])
      end
      
    end
    
    context "change self Put /users/:id" do
      let(:correct_params){{name: 'asdfe'}}
      before { put "/users/#{user.id}", params: correct_params.to_json, headers: valid_headers}
      it "should update the user" do
        expect(response.body).to be_empty
        expect(User.find(user.id).name).to eq(correct_params[:name])
      end
      
      it "should respond with code 204" do
        expect(response).to have_http_status(204)
      end
    end
    
    context "delete other Delete /users/:id" do
      before {delete "/users/#{user_guest.id}", params: {}, headers: valid_headers}
      it "should get 403 response" do
        expect(User.find(user_guest.id).disabled).to eq(false)
        expect(response).to have_http_status(403)
      end
    end
    
    context "delete self Delete /users/:id" do
      before {delete "/users/#{user.id}", params: {}, headers: valid_headers}
      it "should delete the user" do
        expect(User.find(user.id).disabled).to eq(true)
        expect(response.body).to be_empty
      end
      
      it "should respond with code 204" do
        expect(response).to have_http_status(204)
      end
    end
    
    context 'GET /users' do
      #initialize reguest
      before { get '/users', params: {}, headers: valid_headers}
    
      it "sends users" do
        #json implemented in support/request__spec_helpers
        expect(json[0]['role']).to be_nil
        expect(json[0]['disabled']).to be_nil
        expect(json.size).to eq(3)
      end
    
      it "return code 200" do
        expect(response).to have_http_status(200)
      end
    end
    
    context 'GET /users/:id' do
      #initialize reguest
      before { get "/users/#{user.id}", params: {}, headers: valid_headers}
    
      it "sends users" do
        #json implemented in support/request__spec_helpers
        expect(json['role']).to be_nil
        expect(json['disabled']).to be_nil
        expect(json['id']).to eq(user.id)
      end
    
      it "return code 200" do
        expect(response).to have_http_status(200)
      end
    end
  end
  
  
  describe "User admin:" do
    let(:user){user_admin}
    context 'GET /users' do
      #initialize reguest
      before { get '/users', params: {}, headers: valid_headers}
    
      it "sends users" do
        #json implemented in support/request__spec_helpers
        expect(json[0]['role']).not_to be_nil
        expect(json[0]['disabled']).not_to be_nil
        expect(json.size).to eq(4)#disabled one is also shown
      end
    
      it "return code 200" do
        expect(response).to have_http_status(200)
      end
    end
    
    context 'GET /users/:id' do
      #initialize reguest
      before { get "/users/#{user.id}", params: {}, headers: valid_headers}
    
      it "sends user" do
        #json implemented in support/request__spec_helpers
        expect(json['role']).not_to be_nil
        expect(json['disabled']).not_to be_nil
        expect(json['id']).to eq(user.id)
      end
    
      it "return code 200" do
        expect(response).to have_http_status(200)
      end
    end
    
    context "Post /users as admin" do
      let(:correct_params){{name: 'nice name', email: "sdf1@jj.ed", password: "12345678", role: "admin"}}
      before { post '/users', params: correct_params.to_json, headers: valid_headers}
      it "should create user" do
        expect(json['email']).to eq(correct_params[:email])
        expect(User.count).to eq(5)
      end
      it "should respond with code 201" do
        expect(response).to have_http_status(201)
      end
    end
    
    context "Post /users as user" do
      let(:correct_params){{name: 'nice name', email: "sdf2@jj.ed", password: "12345678", role: "user"}}
      before { post '/users', params: correct_params.to_json, headers: valid_headers}
      it "should create user" do
        expect(json['email']).to eq(correct_params[:email])
        expect(User.count).to eq(5)
      end
      it "should respond with code 201" do
        expect(response).to have_http_status(201)
      end
    end
    
    context "Post /users as guest" do
      let(:correct_params){{name: 'nice name', email: "sdf3@jj.ed", password: "12345678", role: "guest"}}
      before { post '/users', params: correct_params.to_json, headers: valid_headers}
      it "should create user" do
        expect(json['email']).to eq(correct_params[:email])
        expect(User.count).to eq(5)
      end
      it "should respond with code 201" do
        expect(response).to have_http_status(201)
      end
    end
    
    context "change other Put /users/:id" do
      let(:correct_params){{name: 'asdfe'}}
      before { put "/users/#{user_guest.id}", params: correct_params.to_json, headers: valid_headers}
      it "should update the user" do
        expect(response.body).to be_empty
        expect(User.find(user_guest.id).name).to eq(correct_params[:name])
      end
      
      it "should respond with code 204" do
        expect(response).to have_http_status(204)
      end
      
    end
    
    context "change self Put /users/:id" do
      let(:correct_params){{name: 'asdfe'}}
      before { put "/users/#{user.id}", params: correct_params.to_json, headers: valid_headers}
      it "should update the user" do
        expect(response.body).to be_empty
        expect(User.find(user.id).name).to eq(correct_params[:name])
      end
      
      it "should respond with code 204" do
        expect(response).to have_http_status(204)
      end
    end
    
    context "delete other Delete /users/:id" do
      before {delete "/users/#{user_guest.id}", params: {}, headers: valid_headers}
      it "should delete the user" do
        expect(User.find(user_guest.id).disabled).to eq(true)
        expect(response.body).to be_empty
      end
      
      it "should respond with code 204" do
        expect(response).to have_http_status(204)
      end
    end
    
    #super admin with id=1
    context "delete self Delete /users/:id" do
      before {delete "/users/#{user.id}", params: {}, headers: valid_headers}
      it "should not delete the user" do
        expect(User.find(user.id).disabled).to eq(false)
      end
      
      it "should respond with code 403" do
        expect(response).to have_http_status(403)
      end
    end
    
    #any other admin
    context "delete self Delete /users/:id" do
      let(:user){create(:user, role: "admin")}
      before {delete "/users/#{user.id}", params: {}, headers: valid_headers}
      it "should delete the user" do
        expect(User.find(user.id).disabled).to eq(true)
      end
      
      it "should respond with code 204" do
        expect(response).to have_http_status(204)
      end
    end
  end
  
  
end