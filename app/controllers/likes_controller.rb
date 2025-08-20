class LikesController < ApplicationController
  before_action :authenticate_user!
  def create
    @comment = Comment.find(params[:comment_id])
    current_user.likes.find_or_create_by(comment: @comment)
    # redirect_to post_path(@comment.post), notice: "Liked!"
    redirect_back fallback_location: root_path,  notice: "Liked!"
  end

  def destroy
    @comment = Comment.find(params[:comment_id])
    like = current_user.likes.find_by(comment: @comment)
    like&.destroy
    #  redirect_to post_path(@comment.post), notice: "UnLiked!"
    redirect_back fallback_location: root_path,  notice: "UnLiked!"
  end
end
