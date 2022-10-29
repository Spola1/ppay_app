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
    params.require(:comment).permit(:text)
  end
end
