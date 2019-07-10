class SessionController < ApplicationController
  def new; end

  def create
    user = User.find_by email: downcase_param_email
    session = params[:session]

    if user&.authenticate session[:password]
      log_in user

      if session[:remember_me] == Settings.remember_me_value
        remember(user)
      else
        forget(user)
      end

      flash[:success] = t ".success"
      redirect_back_or user
    else
      flash[:danger] = t ".danger"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

  def downcase_param_email
    params[:session][:email].downcase
  end
end
