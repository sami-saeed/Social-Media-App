class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [ :edit, :update, :destroy ]

  def index
    @posts = current_user.posts
    @all_posts = Post.all
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = current_user.posts.new
  end

  def create
    @post = current_user.posts.new(post_params)
    if @post.save
      redirect_to @post, notice: "Post created successfully."
    else
      render :new
    end
  end

  def import
    @post = PostFromUrl.new(params[:url], current_user).call
    if @post.save
      redirect_to @post, notice: "Post created from URL successfully."
    else
      redirect_to posts_path, alert: "Error creating post from URL."
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: "Post deleted successfully."
  end


  private

  def set_post
    @post = current_user.posts.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :image)
  end
end
