class CommentsController < ApplicationController

  before_action :authenticate_user!

  def create
    @comment = Comment.create(comment_params)
    @comment.user = current_user
    @payment.comments << @comment
  end

  def update
    @comment = Comment.find(params[:id])
    @comment.update_attributes(comment_params)
  end

  private

  def comment_params
    params.require(:comment).permit(:id,:text,:commentable_id,:commentable_type,:author_nickname,:author_type,:user_id,:user_ip,:user_agent)
  end
end
