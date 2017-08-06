class CommentsController < ApplicationController
  skip_before_action :is_admin_or_user!, only: [:show, :index]
  before_action :get_post
  before_action :get_comment, only: [:update, :destroy, :show]
  before_action :is_owner!, only: [:update, :destroy]
  
  
  def index
    json_response(@post.comments)
  end
  
  def show
    json_response(@comment)
  end
  
  def update
    @comment.update!(comment_params)
    head :no_content
  end
  
  def create
    @comment = @post.comments.new(comment_params)
    @comment.user = @current_user
    @comment.save!
    json_response(@comment,:created)
  end
  
  def destroy
    @comment.destroy
    head :no_content
  end
  
  private
  
  def comment_params
    params.permit(:body)
  end
  
  def get_comment
    @comment = @post.comments.find_by!(id: params[:id]) if @post
  end
  
  def get_post
    @post = Post.find params[:post_id]
  end
  
  def is_owner!
    return true if @current_user.admin? || @current_user.id == @comment.user_id
    raise ExceptionHandler::Forbidden
  end
end
