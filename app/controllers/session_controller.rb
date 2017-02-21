require "resolv"

class SessionController < ApiController

  skip_before_filter :authentication, :authorization, :legal
  skip_before_filter :verify_authenticity_token, only: ['create', 'reset_password']

  def show
    
  end

  def env_auth
    if user = Kor::Auth.env_login(request.env)
      create_session(user)
      
      redirect_to(
        params[:return_to].presence || back ||
        current_user.home_page ||
        Kor.config['app.default_home_page'] ||
        browser_path
      )
    else
      redirect_to root_path(return_to: params[:return_to])
    end
  end

  def create
    if unauthenticated_user = User.find_by(name: params[:username])
      if unauthenticated_user.too_many_login_attempts?
        render_403 I18n.t('errors.too_many_login_attempts')
      else
        if user = Kor::Auth.login(params[:username], params[:password])
          user.update_attributes(:login_attempts => [])

          if user.expires_at && (user.expires_at <= Time.now)
            rendeR_403 I18n.t("errors.account_expired")
          elsif user.inactive?
            reset_session
            render_403 I18n.t("errors.account_inactive")
          else
            user.fix_cryptography(params[:password])
            create_session(user)
            @message = I18n.t('notices.logged_in')
            render action: 'show'
          end
        else
          unauthenticated_user.add_login_attempt
          unauthenticated_user.save
          render_403 I18n.t("errors.user_or_pass_refused")
        end
      end
    else
      render_403 I18n.t("errors.user_or_pass_refused")
    end
  end

  def destroy
    reset_session
    @current_user = nil
    @message = I18n.t("notices.logged_out")
    render action: 'show'
  end

  def reset_password
    @user = User.find_by(email: params[:email])
    
    if @user && !@user.admin?
      @user.reset_password
      @user.save
      UserMailer.reset_password(@user).deliver_now
      @message = I18n.t('notices.personal_password_reset_success')
      render action: 'show'
    else
      render_404 I18n.t('errors.personal_password_reset_mail_not_found')
    end
  end


  protected

    def create_session(user)
      session[:expires_at] = Kor.session_expiry_time
      session[:user_id] = user.id
      user.update_attributes(last_login: Time.now)
      @current_user = nil
    end

end