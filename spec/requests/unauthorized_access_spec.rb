require 'rails_helper'

RSpec.shared_examples "unauthorized access checks" do 
  it "should repond with error" do
    expect(json['error']).not_to be_empty
  end
  
  it "should repond with status 422" do
    expect(response).to have_http_status(422)
  end
end

#This checks that no unauthorized access is granted to all the resources
RSpec.describe 'Unauthorized Access:', type: :request do
  let!(:user) {create(:user)}
  let!(:post_obj) {create(:post, user_id: user.id)}
  let!(:comment) {create(:comment, post_id: post_obj.id, user_id: user.id)}
  #User API
  describe 'Users API:' do
    
    context "Get /users" do
      before { get '/users', params: {}, headers: invalid_headers}
      include_examples "unauthorized access checks"
    end
    
    context "Post /users" do
      let(:correct_params){{name: 'nice name', email: "sdf@jj.ed", password: "1234"}}
      before { post '/users', params: correct_params.to_json, headers: invalid_headers}
      include_examples "unauthorized access checks"
      it "should not create user" do
        expect(User.count).to eq(1)
      end
    end
    
    context "Get /users/:id" do    
      before { get "/users/#{user.id}", params: {}, headers: invalid_headers}
      include_examples "unauthorized access checks"
    end
    
    context "Delete /users/:id" do
      before { delete "/users/#{user.id}", params: {}, headers: invalid_headers}
      include_examples "unauthorized access checks"
      it "should not delete user" do
        expect(User.find(user.id).disabled).to eq(false)
      end
    end
    
    context "Put /users/:id" do
      let(:correct_params){{name: 'asdfe'}}
      before { put "/users/#{user.id}", params: correct_params.to_json, headers: invalid_headers}
      include_examples "unauthorized access checks"
      it "should not change user" do
        expect(User.find(user.id).name).not_to eq(correct_params[:name])
      end
    end
  end
  
  #Post API
  describe 'Posts API:' do
    
    context "Get /posts" do
      before { get '/posts', params: {}, headers: invalid_headers}
      include_examples "unauthorized access checks"
    end
    
    context "Post /posts" do
      let(:correct_params){{title: 'This is a nice title', body: 'A nice post to have', user_id: user.id}}
      before { post '/posts', params: correct_params.to_json, headers: invalid_headers}
      include_examples "unauthorized access checks"
      it "should not create post" do
        expect(Post.count).to eq(1)
      end
    end
    
    context "Get /posts/:id" do    
      before { get "/posts/#{post_obj.id}", params: {}, headers: invalid_headers}
      include_examples "unauthorized access checks"
    end
    
    context "Delete /posts/:id" do
      before { delete "/posts/#{post_obj.id}", params: {}, headers: invalid_headers}
      include_examples "unauthorized access checks"
      it "should not delete post" do
        expect(Post.find(post_obj.id)).not_to be_blank
      end
    end
    
    context "Put /posts/:id" do
      let(:correct_params){{title: 'asdfe'}}
      before { put "/posts/#{post_obj.id}", params: correct_params.to_json, headers: invalid_headers}
      include_examples "unauthorized access checks"
      it "should not change post" do
        expect(Post.find(post_obj.id).title).not_to eq(correct_params[:title])
      end
    end
  end
  
  #Post API
  describe 'Comments API:' do
    
    context "Get /posts/:id/comments" do
      before { get "/posts/#{post_obj.id}/comments", params: {}, headers: invalid_headers}
      include_examples "unauthorized access checks"
    end
    
    context "Post /posts/:id/comments" do
      let(:correct_params){{body: 'A nice post to have', user_id: user.id, post_id: post_obj.id}}
      before { post "/posts/#{post_obj.id}/comments", params: correct_params.to_json, headers: invalid_headers}
      include_examples "unauthorized access checks"
      it "should not create comment" do
        expect(Comment.count).to eq(1)
      end
    end
    
    context "Get /posts/:id/comments/:id" do    
      before { get "/posts/#{post_obj.id}/comments/#{comment.id}", params: {}, headers: invalid_headers}
      include_examples "unauthorized access checks"
    end
    
    context "Delete /posts/:id/comments/:id" do
      before { delete "/posts/#{post_obj.id}/comments/#{comment.id}", params: {}, headers: invalid_headers}
      include_examples "unauthorized access checks"
      it "should not delete comment" do
        expect(Comment.find(comment.id)).not_to be_blank
      end
    end
    
    context "Put /posts/:id/comments/:id" do
      let(:correct_params){{body: 'asdfe'}}
      before { put "/posts/#{post_obj.id}/comments/#{comment.id}", params: correct_params.to_json, headers: invalid_headers}
      include_examples "unauthorized access checks"
      it "should not change comment" do
        expect(Comment.find(comment.id).body).not_to eq(correct_params[:body])
      end
    end
  end
end