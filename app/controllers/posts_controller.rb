class PostsController < ApplicationController
  skip_before_action :is_admin_or_user!, only: [:show, :index]
  before_action :get_post, only: [:update, :destroy, :show]
  before_action :is_owner!, only: [:update, :destroy]
  
  def index
    @posts = Post.all
    json_response(@posts)
  end
  
  def show
    json_response(@post)
  end
  
  def create
    @post = @current_user.posts.create!(post_params)
    json_response(@post, :created)
  end
  
  def update
    @post.update!(post_params)
    head :no_content
  end
  
  def destroy
    @post.destroy!
    head :no_content
  end
  
  private
  
  def post_params
    params.permit(:body, :title)
  end
  
  def get_post
    @post = Post.find params[:id]
  end
  
  def is_owner!
    return true if @current_user.admin? || @current_user.id == @post.user_id
    raise ExceptionHandler::Forbidden
  end
end
