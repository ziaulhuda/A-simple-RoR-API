require 'rails_helper'

RSpec.describe 'Authorization API', type: :request do
  
  let!(:user){create(:user)}
  let!(:user_disabled){create(:user, disabled: true)}
  let(:user_id){user.id}
  
  describe 'Disbled user' do
    context "cannot login" do
      let(:correct_credentials){{email: user_disabled.email, password: "12345678"}}
      before {post '/signin', params: correct_credentials}
      
      it "returns validation error" do
        expect(json['error']).to match(/Invalid credentials/)
      end
    
      it "should respond with code 401" do
        expect(response).to have_http_status(401)
      end
    end
  end
  
  #Post /sessions
  describe 'POST /sessions' do
    
    context 'with valid credentials' do
      #password defined in user factory
      let(:correct_credentials){{email: user.email, password: "12345678"}}
    
      before {post '/signin', params: correct_credentials}
      
      it "should return the authentication token in headers" do
        expect(json['auth_token']).to eq(user[:auth_token])
      end
      
      it "should respond with code 201" do
        expect(response).to have_http_status(201)
      end
    end
    
    context 'with invalid credentials' do
      let(:incorrect_credentials){{email: user.email, password: "123456"}}
      before {post '/signin', params: incorrect_credentials }
  
      it "returns validation error" do
        expect(json['error']).to match(/Invalid credentials/)
      end
    
      it "should respond with code 401" do
        expect(response).to have_http_status(401)
      end
    end
  
  end
  
  #Delete /sessions #id
  describe 'DELETE /sessions/:id' do
    
    context "with invalid token" do
      before {delete "/signout/#{user_id}", params: {}, headers: invalid_headers}
      
      it "should return invalid token error" do
        expect(json['error']).to match(/Invalid token/)
      end
      
      it "should respond with code 422" do
        expect(response).to have_http_status(422)
      end
      
    end
    
    context 'with valid user id' do
      before {delete "/signout/#{user_id}", params: {}, headers: valid_headers}
    
      it "should delete the session" do
        expect(response.body).to be_empty
        expect(User.find(user_id).auth_token).not_to eq(user.auth_token)
      end
      
      it "should respond with code 204" do
        expect(response).to have_http_status(204)
      end
    end
    
    context 'with not own user id' do
      before {delete "/signout/5", params: {}, headers: valid_headers}
        
      it "should return forbidden action" do
        expect(json['error']).to match(/Action forbidden/)
      end
    
      it "should respond with code 403" do
        expect(response).to have_http_status(403)
      end
    end
  
  end
  
end