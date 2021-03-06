class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(show new create)
  before_action :load_user, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.all.page(params[:page]).per Settings.paginate_user
  end

  def show
    redirect_to(root_url) && return unless @user
    @microposts = @user.microposts.page(params[:page])
                       .per Settings.paginate_post
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      @user.send_activation_email
      flash[:info] = t ".info"
      redirect_to root_url
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update_attributes user_params
      flash[:success] = t ".success"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t ".success"
    else
      flash[:danger] = t ".danger"
    end
    redirect_to users_url
  end

  def following
    @title = t ".following"
    @users = @user.following.page(params[:page]).per Settings.paginate_user
    render :show_follow
  end

  def followers
    @title = t ".followers"
    @users = @user.followers.page(params[:page]).per Settings.paginate_user
    render :show_follow
  end

  private

  def user_params
    params.require(:user)
          .permit :name, :email, :password, :password_confirmation
  end

  def logged_in_user
    return if logged_in?
    store_location
    flash[:danger] = t ".danger"
    redirect_to login_url
  end

  def correct_user
    return if current_user?(@user)
    flash[:danger] = t ".danger_f"
    redirect_to root_url
  end

  def admin_user
    return if current_user.admin?
    flash[:danger] = t ".danger_f"
    redirect_to root_url
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user
    flash[:warning] = t ".warning"
    redirect_to root_path
  end
end
