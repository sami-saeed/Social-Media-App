class UsersController < ApplicationController
   before_action :authenticate_user!
  def index
    @users=User.all
  end



  def show
    @user = User.find_by(id: params[:id])
    @posts = @user.posts
  end


  def all_usernames
    usernames = User.pluck(:username)
    render json: usernames
  end
end
