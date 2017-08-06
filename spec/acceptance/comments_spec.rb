require 'acceptance_helper'

resource "Comments" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"
  
  let!(:user){create(:user, role: "admin")}
  let!(:post_obj){create(:post, user_id: user.id)}
  let(:post_id){post_obj.id}
  let!(:comments){create_list(:comment, 5, post_id: post_obj.id, user_id: user.id)}
  before{header "Authorization", user.auth_token}
  
  explanation "API to handel Comment resource. Authorization required ."
    
  get "/posts/:post_id/comments/" do
    response_field :id, "ID of the comment", "Type" => "Number"
    response_field :body, "Contents of the comment", "Type" => "Text"
    response_field :post_id, "ID of the post this comment is related to", "Type" => "Number"
    response_field :user_id, "ID of the creator", "Type" => "Number"
    
    example_request "Getting a list of comments" do
      expect(json.size).to eq(5)
      expect(status).to eq(200)
    end
  end
  
  get "/posts/:post_id/comments/:id" do
      let(:id) { comments[3].id }
      
      response_field :id, "ID of the comment", "Type" => "Number"
      response_field :body, "Contents of the comment", "Type" => "Text"
      response_field :post_id, "ID of the post this comment is related to", "Type" => "Number"
      response_field :user_id, "ID of the creator", "Type" => "Number"

      example_request "Getting a specific comment" do
        expect(json['id']).to eq(comments[3].id)
        expect(status).to eq(200)
      end
    end
    
    post "/posts/:post_id/comments/" do
      with_options :required => true do
        parameter :body, "Contents of the comments"
      end
       
      response_field :id, "ID of the comment", "Type" => "Number"
      response_field :body, "Contents of the comment", "Type" => "Text"
      response_field :post_id, "ID of the post this comment is related to", "Type" => "Number"
      response_field :user_id, "ID of the creator", "Type" => "Number"
      
      let(:body) { Faker::Lorem.paragraphs().join(" ") }

      let(:raw_post) { params.to_json }

      example_request "Creating a comment" do
        explanation "Admin and \"user\" can create comments. Guest users cannot create a comment."

        expect(json['body']).to eq(body)
        expect(status).to eq(201)

      end
    end
    
    put "/posts/:post_id/comments/:id" do
      let(:id) { comments[3].id }
      with_options :required => false do
        parameter :body, "Contents of the comment"
      end
      
      let(:body) { "A wonderful post" }
      let(:raw_post) { params.to_json }

      example_request "Updating a comment" do
        explanation "Admin can update any comment. \"user\" type users can only update their own comments. Guests cannot update any comment."

        expect(response_body).to be_empty
        expect(status).to eq(204)

      end
    end
    
    delete "/posts/:post_id/comments/:id" do
      let(:id) { comments[3].id }
      
      example_request "Deleting a comment" do
        explanation "Admin can delete any comment. \"user\" type users can only delete their own comments. Guests cannot delete any comment."

        expect(response_body).to be_empty
        expect(status).to eq(204)

      end
    end
end