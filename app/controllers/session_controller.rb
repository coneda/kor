class SessionController < JsonController
  protect_from_forgery except: [:create, :destroy, :reset_password]

  skip_before_filter :auth, :legal

  def show
  end

  def env_auth
    if user = Kor::Auth.env_login(request.env)
      create_session(user)
    end

    redirect_to '/'
  end

  # TODO: make this more secure!
  def recovery
    @user = User.find_by(email: params[:email])

    if @user
      if @user.admin?
        render_422 nil, I18n.t('messages.personal_password_reset_no_admins')
      else
        @user.reset_password
        @user.save
        UserMailer.reset_password(@user).deliver_now
        render_200 I18n.t('messages.personal_password_reset_success')
      end
    else
      render_404 I18n.t('messages.personal_password_reset_mail_not_found')
    end
  end

  def create
    account_without_password = User.find_by_name(params[:username])
    if account_without_password && account_without_password.too_many_login_attempts?
      render_403 I18n.t('messages.too_many_login_attempts')
    else
      account = Kor::Auth.login(params[:username], params[:password])

      if account
        account.update_attributes(login_attempts: [])

        if account.expires_at && (account.expires_at <= Time.now)
          render_403 I18n.t("messages.account_expired")
        elsif !account.active
          reset_session
          render_403 I18n.t("messages.account_inactive")
        else
          account.fix_cryptography(params[:password])
          create_session(account)
          render_200 I18n.t('messages.logged_in')
        end
      else
        if account_without_password
          account_without_password.add_login_attempt
          account_without_password.save
        end

        reset_session
        render_403 I18n.t("messages.user_or_pass_refused")
      end
    end
  end

  def destroy
    reset_session
    render_200 I18n.t("messages.logged_out")
  end

  protected

    def create_session(user)
      session[:user_id] = user.id
      @current_user = nil
      session[:expires_at] = Kor.session_expiry_time
      user.update_attributes(last_login: Time.now)
    end
end
