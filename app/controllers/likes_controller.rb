class LikesController < ApplicationController
  before_action :authenticate_user!
  def create
    @comment = Comment.find(params[:comment_id])
    current_user.likes.find_or_create_by(comment: @comment)
    Notification.create!(
          recipient: @comment.user,
          actor: current_user,
          notifiable: @comment,
          action: "liked your comment"
        ) unless current_user == @comment.user
  if @comment.post.user != @comment.user && current_user != @comment.post.user
    Notification.create!(
          recipient: @comment.post.user,
          actor: current_user,
          notifiable: @comment,
          action: "liked a comment in your post"
        )

    # redirect_to post_path(@comment.post), notice: "Liked!"
    redirect_back fallback_location: root_path,  notice: "Liked!"
  end
  end

  def destroy
    @comment = Comment.find(params[:comment_id])
    like = current_user.likes.find_by(comment: @comment)
    like&.destroy
    #  redirect_to post_path(@comment.post), notice: "UnLiked!"
    redirect_back fallback_location: root_path,  notice: "UnLiked!"
  end
end
