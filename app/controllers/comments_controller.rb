class CommentsController < ApplicationController
  def create
      if params[:post_id]
        @post = Post.find(params[:post_id])
        @comment = @post.comments.build(comment_params)
        @comment.user = current_user
      else
        @parent_comment = Comment.find(params[:comment_id])
        @post = @parent_comment.post
        @comment = @post.comments.build(comment_params)
        @comment.user = current_user
        @comment.parent = @parent_comment

      end

      if @comment.save
       redirect_back fallback_location: root_path, notice: "Comment Posted"
      else
        redirect_back fallback_location: root_path, alert: "Error Posting Comment"
      end
  end


  def destroy
    if params[:id]
      @comment = Comment.find_by(id: params[:id])
      if @comment && @comment.user == current_user
         @comment&.destroy
         flash[:alert] = "Comment deleted"
      else
         flash[:alert] = "You are not authorized to delete this comment."
      end

      redirect_back fallback_location: root_path
    end
  end


     private
        def comment_params
          params.require(:comment).permit(:content)
        end
end
