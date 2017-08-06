require 'rails_helper'

RSpec.shared_examples "Get posts" do 
  #Get /posts
  context 'GET /posts' do
    #initialize reguest
    before { get '/posts', params: {}, headers: valid_headers}    
    it "sends posts" do
      #json implemented in support/request__spec_helpers
      expect(json).not_to be_empty
      expect(json.size).to eq(2)
    end
  
    it "return code 200" do
      expect(response).to have_http_status(200)
    end
  end
  
  #Get /posts #id
  context 'GET /posts/:id' do
    #initialize reguest
    before { get "/posts/#{post_id}", params: {}, headers: valid_headers}

    context 'when the post exists' do
      let(:post_id) {post_admin.id}
      it "sends post with id" do
        expect(json).not_to be_empty
        expect(json['id']).to eq(post_id)
      end

      it "returns code 200" do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the post doesn\'t exist' do
      let(:post_id) {0}
  
      it "has error message" do
        expect(json['error']).not_to be_empty
      end
  
      it "returns code 404" do
        expect(response).to have_http_status(404)
      end
    end
  end
end

RSpec.shared_examples "Post posts" do 
  context "POST /posts" do
  
    context 'with valid post object' do
      let(:correct_params){{title: 'This is a nice title', body: 'A nice post to have', user_id: user.id}}
  
      before {post '/posts', params: correct_params.to_json, headers: valid_headers}
  
      it "should create a new post" do
        expect(json['error']).to be_nil
        expect(Post.count).to eq(3)
      end
    
      it "should respond with code 201" do
        expect(response).to have_http_status(201)
      end
    end
  
    context 'with invalid post object' do
      let(:incorrect_params){{title: "This is a nice title"}}
      before {post '/posts', params: incorrect_params.to_json, headers: valid_headers}

      it "should not create a new post" do
        expect(json['error']).not_to be_empty
        expect(Post.count).to eq(2)
      end
  
      it "should respond with code 422" do
        expect(response).to have_http_status(422)
      end
    end
  end
end

RSpec.shared_examples "Put invalid post id" do 
  
  context 'with invalid post id' do
    let(:correct_params){{title: "A Great Post"}}
    before {put "/posts/0", params: correct_params.to_json, headers: valid_headers}
  
    it "should return with error" do
      expect(json['error']).not_to be_empty
    end

    it "should respond with code 404" do
      expect(response).to have_http_status(404)
    end
  end
  
end

RSpec.shared_examples "Delete invalid post id" do
  context 'with invalid post id' do
    before {delete "/posts/0", params: {}, headers: valid_headers}
  
    it "should return with error" do
      expect(json['error']).not_to be_empty
      expect(Post.count).to eq(2)
    end

    it "should respond with code 404" do
      expect(response).to have_http_status(404)
    end
  end
end

RSpec.describe 'Posts API:', type: :request do
  
  #test data
  let!(:user_admin) {create(:user, role: "admin")}
  let!(:user_user) {create(:user, role: "user")}
  let!(:user_guest) {create(:user, role: "guest")}
  
  let!(:post_admin) {create(:post, user_id: user_admin.id)}
  let!(:post_user) {create(:post, user_id: user_user.id)}
  
  
  describe "Geust users:" do
    let(:user){user_guest}
    
    include_examples "Get posts"
    
    context "POST /posts" do
    
      context 'with valid post object' do
        let(:correct_params){{title: 'This is a nice title', body: 'A nice post to have', user_id: user.id}}
    
        before {post '/posts', params: correct_params.to_json, headers: valid_headers}
    
        it "should not create a new post" do
          expect(json['error']).not_to be_empty
          expect(Post.count).to eq(2)
        end
      
        it "should respond with code 403" do
          expect(response).to have_http_status(403)
        end
      end
    
      context 'with invalid post object' do
        let(:incorrect_post){{title: "This is a nice title"}}
        before {post '/posts', params: incorrect_post.to_json, headers: valid_headers}

        it "should not create a new post" do
          expect(json['error']).not_to be_empty
          expect(Post.count).to eq(2)
        end
    
        it "should respond with code 403" do
          expect(response).to have_http_status(403)
        end
      end
    end
    
    #Put/Patch /posts #id
    context 'PUT /posts/:id' do
  
      context 'with valid post id' do
        let(:correct_params){{title: 'Our great Leader'}}
  
        before {put "/posts/#{post_user.id}", params: correct_params.to_json, headers: valid_headers}
  
        it "should not update the post" do
          expect(json['error']).not_to be_empty
          expect(Post.find(post_user.id)).not_to eq(correct_params[:title])
        end
    
        it "should respond with code 403" do
          expect(response).to have_http_status(403)
        end
      end
  
      context 'with invalid post id' do
        let(:correct_params){{title: "A Great Post"}}
        before {put "/posts/0", params: correct_params.to_json, headers: valid_headers}
      
        it "should return with error" do
          expect(json['error']).not_to be_empty
        end
  
        it "should respond with code 403" do
          expect(response).to have_http_status(403)
        end
      end

    end
      
    #Delete /posts #id
    context 'DELETE /posts/:id' do
  
      context 'with valid post id' do
        before {delete "/posts/#{post_user.id}", params: {}, headers: valid_headers}
  
        it "should not delete the post" do
          expect(json['error']).not_to be_empty
          expect(Post.count).to eq(2)
        end
    
        it "should respond with code 403" do
          expect(response).to have_http_status(403)
        end
      end
  
      context 'with invalid post id' do
        before {delete "/posts/0", params: {}, headers: valid_headers}
      
        it "should return with error" do
          expect(json['error']).not_to be_empty
          expect(Post.count).to eq(2)
        end
  
        it "should respond with code 403" do
          expect(response).to have_http_status(403)
        end
      end
    end
  end
  
  describe "User users:" do
    let(:user){user_user}
    
    include_examples "Get posts"
    
    include_examples "Post posts"
    
    #Put/Patch /posts #id
    context 'PUT /posts/:id' do
  
      include_examples "Put invalid post id"
      
      context 'with valid post id' do
        let(:correct_params){{title: 'Our great Leader'}}
        
        context 'own post' do
          before {put "/posts/#{post_user.id}", params: correct_params.to_json, headers: valid_headers}
  
          it "should update the post" do
            expect(response.body).to be_empty
            expect(Post.find(post_user.id).title).to eq(correct_params[:title])
          end
    
          it "should respond with code 204" do
            expect(response).to have_http_status(204)
          end
        end
        
        context "other's post" do
          before {put "/posts/#{post_admin.id}", params: correct_params.to_json, headers: valid_headers}
  
          it "should not update the post" do
            expect(json['error']).not_to be_empty
            expect(Post.find(post_admin.id).title).not_to eq(correct_params[:title])
          end
    
          it "should respond with code 403" do
            expect(response).to have_http_status(403)
          end
        end
        
      end

    end
      
    #Delete /posts #id
    context 'DELETE /posts/:id' do
  
      include_examples "Delete invalid post id"
      
      context 'with valid post id' do
        
        context 'own post' do
          before {delete "/posts/#{post_user.id}", params: {}, headers: valid_headers}
  
          it "should delete the post" do
            expect(response.body).to be_empty
            expect(Post.count).to eq(1)
          end
    
          it "should respond with code 204" do
            expect(response).to have_http_status(204)
          end
        end
        
        context 'Other\'s post' do
          before {delete "/posts/#{post_admin.id}", params: {}, headers: valid_headers}
  
          it "should return with error" do
            expect(json['error']).not_to be_empty
            expect(Post.count).to eq(2)
          end

          it "should respond with code 404" do
            expect(response).to have_http_status(403)
          end
        end
        
      end
    end
  end
  
  describe "Admin users:" do
    let(:user){user_admin}
    
    include_examples "Get posts"
    
    include_examples "Post posts"
    
    #Put/Patch /posts #id
    context 'PUT /posts/:id' do
    
      include_examples "Put invalid post id"
      
      context 'with valid post id' do
        let(:correct_params){{title: 'Our great Leader'}}
      
        context 'own post' do
          before {put "/posts/#{post_admin.id}", params: correct_params.to_json, headers: valid_headers}

          it "should update the post" do
            expect(response.body).to be_empty
            expect(Post.find(post_admin.id).title).to eq(correct_params[:title])
          end
  
          it "should respond with code 204" do
            expect(response).to have_http_status(204)
          end
        end
      
        context "other's post" do
          before {put "/posts/#{post_user.id}", params: correct_params.to_json, headers: valid_headers}

          it "should update the post" do
            expect(response.body).to be_empty
            expect(Post.find(post_user.id).title).to eq(correct_params[:title])
          end
  
          it "should respond with code 204" do
            expect(response).to have_http_status(204)
          end
        end
      end
      
    end
      
    #Delete /posts #id
    context 'DELETE /posts/:id' do
  
      include_examples "Delete invalid post id"
      
      context 'with valid post id' do
        
        context 'own post' do
          before {delete "/posts/#{post_admin.id}", params: {}, headers: valid_headers}
  
          it "should delete the post" do
            expect(response.body).to be_empty
            expect(Post.count).to eq(1)
          end
    
          it "should respond with code 204" do
            expect(response).to have_http_status(204)
          end
        end
        
        context "other's post" do
          before {delete "/posts/#{post_user.id}", params: {}, headers: valid_headers}
  
          it "should delete the post" do
            expect(response.body).to be_empty
            expect(Post.count).to eq(1)
          end
    
          it "should respond with code 204" do
            expect(response).to have_http_status(204)
          end
        end
        
      end
    end
  end
  
end