require 'rails_helper'

RSpec.shared_examples "Get comments" do 
  #Get /posts
  context 'GET /posts/:post_id/comments' do
    #initialize reguest
    before { get "/posts/#{post_obj.id}/comments", params: {}, headers: valid_headers}    
    it "sends comments" do
      #json implemented in support/request__spec_helpers
      expect(json).not_to be_empty
      expect(json.size).to eq(2)
    end
  
    it "return code 200" do
      expect(response).to have_http_status(200)
    end
  end
  
  #Get /posts #id
  context 'GET /posts/:post_id/comments/:id' do
    #initialize reguest
    before { get "/posts/#{post_id}/comments/#{comment_id}", params: {}, headers: valid_headers}
    let(:post_id){post_obj.id}
    context 'when the comment exists' do
      let(:comment_id) {comment_admin.id}
      it "sends comment with id" do
        expect(json).not_to be_empty
        expect(json['id']).to eq(comment_id)
      end

      it "returns code 200" do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the comment doesn\'t exist' do
      let(:comment_id) {0}
  
      it "has error message" do
        expect(json['error']).not_to be_empty
      end
  
      it "returns code 404" do
        expect(response).to have_http_status(404)
      end
    end
    
    context "when post_id is invalid" do
      let(:comment_id) {comment_admin.id}
      let(:post_id){0}
      it "has error message" do
        expect(json['error']).not_to be_empty
      end
  
      it "returns code 404" do
        expect(response).to have_http_status(404)
      end
    end
  end
end

RSpec.shared_examples "Post comments" do 
  context "POST /posts/:post_id/comments/" do
  
    context 'with valid comment object' do
      let(:correct_params){{body: 'A nice comment to have'}}
  
      before {post "/posts/#{post_obj.id}/comments", params: correct_params.to_json, headers: valid_headers}
  
      it "should create a new comment" do
        expect(json['error']).to be_nil
        expect(Comment.count).to eq(3)
      end
    
      it "should respond with code 201" do
        expect(response).to have_http_status(201)
      end
    end
  
    context 'with invalid comment object' do
      let(:incorrect_params){{body: nil}}
      before {post '/posts', params: incorrect_params.to_json, headers: valid_headers}

      it "should not create a new comment" do
        expect(json['error']).not_to be_empty
        expect(Comment.count).to eq(2)
      end
  
      it "should respond with code 422" do
        expect(response).to have_http_status(422)
      end
    end
  end
end

RSpec.shared_examples "Put invalid comment id" do 
  
  context 'with invalid comment id' do
    let(:correct_params){{body: "A Great Post"}}
    before {put "/posts/#{post_obj.id}/comments/0", params: correct_params.to_json, headers: valid_headers}
  
    it "should return with error" do
      expect(json['error']).not_to be_empty
    end

    it "should respond with code 404" do
      expect(response).to have_http_status(404)
    end
  end
  
end

RSpec.shared_examples "Delete invalid comment id" do
  context 'with invalid comment id' do
    before {delete "/posts/#{post_obj.id}/comments//0", params: {}, headers: valid_headers}
  
    it "should return with error" do
      expect(json['error']).not_to be_empty
      expect(Comment.count).to eq(2)
    end

    it "should respond with code 404" do
      expect(response).to have_http_status(404)
    end
  end
end

RSpec.describe 'Comments API:', type: :request do
  
  #test data
  let!(:user_admin) {create(:user, role: "admin")}
  let!(:user_user) {create(:user, role: "user")}
  let!(:user_guest) {create(:user, role: "guest")}
  
  let!(:post_obj) {create(:post, user_id: user_admin.id)}
  
  let!(:comment_admin) {create(:comment, post_id: post_obj.id, user_id: user_admin.id)}
  let!(:comment_user) {create(:comment, post_id: post_obj.id, user_id: user_user.id)}
  
  
  describe "Geust users:" do
    let(:user){user_guest}
    
    include_examples "Get comments"
    
    context "POST /posts/:post_id/comments/" do
      context 'with valid comment object' do
        let(:correct_params){{body: 'A nice comment to have'}}

        before {post "/posts/#{post_obj.id}/comments/", params: correct_params.to_json, headers: valid_headers}

        it "should not create a new comment" do
          expect(json['error']).not_to be_empty
          expect(Comment.count).to eq(2)
        end
  
        it "should respond with code 403" do
          expect(response).to have_http_status(403)
        end
      end

      context 'with invalid comment object' do
        let(:incorrect_post){{body: "This is a nice title"}}
        before {post '/posts', params: incorrect_post.to_json, headers: valid_headers}

        it "should not create a new comment" do
          expect(json['error']).not_to be_empty
          expect(Comment.count).to eq(2)
        end

        it "should respond with code 403" do
          expect(response).to have_http_status(403)
        end
      end          
    end
    
    #Put/Patch /posts #id
    context 'PUT /posts/:post_id/comments/:id' do

      context 'with valid comment id' do
        let(:correct_params){{body: 'Our great Leader'}}

        before {put "/posts/#{post_obj.id}/comments/#{comment_user.id}", params: correct_params.to_json, headers: valid_headers}

        it "should not update the comment" do
          expect(json['error']).not_to be_empty
          expect(Comment.find(comment_user.id)).not_to eq(correct_params[:body])
        end

        it "should respond with code 403" do
          expect(response).to have_http_status(403)
        end
      end

      context 'with invalid comment id' do
        let(:correct_params){{body: "A Great Post"}}
        before {put "/posts/#{post_obj.id}/comments/0", params: correct_params.to_json, headers: valid_headers}
  
        it "should return with error" do
          expect(json['error']).not_to be_empty
        end

        it "should respond with code 403" do
          expect(response).to have_http_status(403)
        end
      end
    end
    
    #Delete /posts #id
    context 'DELETE /posts/:post_id/comments/:id' do
      context 'with valid comment id' do
        before {delete "/posts/#{post_obj.id}/comments/#{comment_user.id}", params: {}, headers: valid_headers}

        it "should not delete the comment" do
          expect(json['error']).not_to be_empty
          expect(Comment.count).to eq(2)
        end

        it "should respond with code 403" do
          expect(response).to have_http_status(403)
        end
      end

      context 'with invalid comment id' do
        before {delete "/posts/0", params: {}, headers: valid_headers}
  
        it "should return with error" do
          expect(json['error']).not_to be_empty
          expect(Comment.count).to eq(2)
        end

        it "should respond with code 403" do
          expect(response).to have_http_status(403)
        end
      end
    end
    
  end
  
  describe "User users:" do
    let(:user){user_user}
    
    include_examples "Get comments"
    
    include_examples "Post comments"
    
    #Put/Patch /posts #id
    context 'PUT /posts/:post_id/comments/:id' do
  
      include_examples "Put invalid comment id"
      
      context 'with valid comment id' do
        let(:correct_params){{body: 'Our great Leader'}}
        
        context 'own comment' do
          before {put "/posts/#{post_obj.id}/comments/#{comment_user.id}", params: correct_params.to_json, headers: valid_headers}
  
          it "should update the comment" do
            expect(response.body).to be_empty
            expect(Comment.find(comment_user.id).body).to eq(correct_params[:body])
          end
    
          it "should respond with code 204" do
            expect(response).to have_http_status(204)
          end
        end
        
        context "other's comment" do
          before {put "/posts/#{post_obj.id}/comments/#{comment_admin.id}", params: correct_params.to_json, headers: valid_headers}
  
          it "should not update the comment" do
            expect(json['error']).not_to be_empty
            expect(Comment.find(comment_admin.id).body).not_to eq(correct_params[:body])
          end
    
          it "should respond with code 403" do
            expect(response).to have_http_status(403)
          end
        end
        
      end

    end
      
    #Delete /posts #id
    context 'DELETE /posts/:post_id/comments/:id' do
  
      include_examples "Delete invalid comment id"
      
      context 'with valid post id' do
        
        context 'own post' do
          before {delete "/posts/#{post_obj.id}/comments/#{comment_user.id}", params: {}, headers: valid_headers}
  
          it "should delete the post" do
            expect(response.body).to be_empty
            expect(Comment.count).to eq(1)
          end
    
          it "should respond with code 204" do
            expect(response).to have_http_status(204)
          end
        end
        
        context 'Other\'s comment' do
          before {delete "/posts/#{post_obj.id}/comments/#{comment_admin.id}", params: {}, headers: valid_headers}
  
          it "should return with error" do
            expect(json['error']).not_to be_empty
            expect(Comment.count).to eq(2)
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
    
    include_examples "Get comments"
    
    include_examples "Post comments"
    
    #Put/Patch /posts #id
    context 'PUT /posts/:post_id/comments/:id' do
    
      include_examples "Put invalid comment id"
      
      context 'with valid post id' do
        let(:correct_params){{body: 'Our great Leader'}}
      
        context 'own comment' do
          before {put "/posts/#{post_obj.id}/comments/#{comment_admin.id}", params: correct_params.to_json, headers: valid_headers}

          it "should update the post" do
            expect(response.body).to be_empty
            expect(Comment.find(comment_admin.id).body).to eq(correct_params[:body])
          end
  
          it "should respond with code 204" do
            expect(response).to have_http_status(204)
          end
        end
      
        context "other's comment" do
          before {put "/posts/#{post_obj.id}/comments/#{comment_user.id}", params: correct_params.to_json, headers: valid_headers}

          it "should update the post" do
            expect(response.body).to be_empty
            expect(Comment.find(comment_user.id).body).to eq(correct_params[:body])
          end
  
          it "should respond with code 204" do
            expect(response).to have_http_status(204)
          end
        end
      end
      
    end
      
    #Delete /posts #id
    context 'DELETE /posts/:post_id/comments/:id' do
  
      include_examples "Delete invalid comment id"
      
      context 'with valid comment id' do
        
        context 'own post' do
          before {delete "/posts/#{post_obj.id}/comments/#{comment_admin.id}", params: {}, headers: valid_headers}
  
          it "should delete the post" do
            expect(response.body).to be_empty
            expect(Comment.count).to eq(1)
          end
    
          it "should respond with code 204" do
            expect(response).to have_http_status(204)
          end
        end
        
        context "other's post" do
          before {delete "/posts/#{post_obj.id}/comments/#{comment_user.id}", params: {}, headers: valid_headers}
  
          it "should delete the post" do
            expect(response.body).to be_empty
            expect(Comment.count).to eq(1)
          end
    
          it "should respond with code 204" do
            expect(response).to have_http_status(204)
          end
        end
        
      end
    end
  end
  
end