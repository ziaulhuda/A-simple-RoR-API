require 'acceptance_helper'

resource "Posts" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"
  
  let!(:user){create(:user, role: "admin")}
  let!(:posts){create_list(:post, 5, user_id: user.id)}
  before{header "Authorization", user.auth_token}
  
  explanation "API to handel Post resource. Authorization required ."
    
  get "/posts" do
    response_field :id, "ID of the post", "Type" => "Number"
    response_field :title, "Title of the post", "Type" => "String"
    response_field :body, "Contents of the post", "Type" => "Text"
    response_field :user_id, "ID of the creator", "Type" => "Number"
    
    example_request "Getting a list of posts" do
      expect(json.size).to eq(5)
      expect(status).to eq(200)
    end
  end
  
  get "/posts/:id" do
      let(:id) { posts[3].id }
      
      response_field :id, "ID of the post", "Type" => "Number"
      response_field :title, "Title of the post", "Type" => "String"
      response_field :body, "Contents of the post", "Type" => "Text"
      response_field :user_id, "ID of the creator", "Type" => "Number"

      example_request "Getting a specific post" do
        expect(json['id']).to eq(posts[3].id)
        expect(status).to eq(200)
      end
    end
    
    post "/posts" do
      with_options :required => true do
        parameter :title, "Title of the post"
        parameter :body, "Contents of the post"
      end
       
      response_field :id, "ID of the post", "Type" => "Number"
      response_field :title, "Title of the post", "Type" => "String"
      response_field :body, "Contents of the post", "Type" => "Text"
      response_field :user_id, "ID of the creator", "Type" => "Number"
      
      let(:title) { "A wonderful post" }
      let(:body) { Faker::Lorem.paragraphs().join(" ") }

      let(:raw_post) { params.to_json }

      example_request "Creating a post" do
        explanation "Admin and \"user\" can create posts. Guest users cannot create a post."

        expect(json['title']).to eq(title)
        expect(status).to eq(201)

      end
    end
    
    put "/posts/:id" do
      let(:id) { posts[3].id }
      with_options :required => false do
        parameter :title, "Title of the post"
        parameter :body, "Contents of the post"
      end
      
      let(:title) { "A wonderful post" }
      let(:raw_post) { params.to_json }

      example_request "Updating a post" do
        explanation "Admin can update any post. \"user\" type users can only update their own posts. Guests cannot update any post."

        expect(response_body).to be_empty
        expect(status).to eq(204)

      end
    end
    
    delete "/posts/:id" do
      let(:id) { posts[3].id }
      
      example_request "Deleting a post" do
        explanation "Admin can delete any post. \"user\" type users can only delete their own posts. Guests cannot delete any post."

        expect(response_body).to be_empty
        expect(status).to eq(204)

      end
    end
end