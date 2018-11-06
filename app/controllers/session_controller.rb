# TOTO: test this
# TODO: diff with json authentication_controller
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
        render_422 nil, I18n.t('errors.personal_password_reset_no_admins')
      else
        @user.reset_password
        @user.save
        UserMailer.reset_password(@user).deliver_now
        render_200 I18n.t('notices.personal_password_reset_success')
      end
    else
      render_404 I18n.t('errors.personal_password_reset_mail_not_found')
    end
  end
  
  def create
    account_without_password = User.find_by_name(params[:username])
    if account_without_password && account_without_password.too_many_login_attempts?
      render_403 I18n.t('errors.too_many_login_attempts')
    else
      account = Kor::Auth.login(params[:username], params[:password])

      if account
        account.update_attributes(login_attempts: [])

        if account.expires_at && (account.expires_at <= Time.now)
          render_403 I18n.t("errors.account_expired")
        elsif !account.active
          reset_session
          render_403 I18n.t("errors.account_inactive")
        else
          account.fix_cryptography(params[:password])
          create_session(account)
          render_200 I18n.t('notices.logged_in')
        end
      else
        if account_without_password
          account_without_password.add_login_attempt
          account_without_password.save
        end

        # TODO: check this:
        # reset_session cant be done here because of http://railsforum.com/viewtopic.php?id=1611 (dead link)
        reset_session
        render_403 I18n.t("errors.user_or_pass_refused")
      end
    end
  end
  
  def destroy
    reset_session
    render_200 I18n.t("notices.logged_out")
  end


  protected

    def create_session(user)
      session[:user_id] = user.id
      @current_user = nil
      session[:expires_at] = Kor.session_expiry_time
      user.update_attributes(last_login: Time.now)
    end

    # TODO: probably not needed anymore
    # def redirect_after_login
    #   r_to = 
    #     params[:return_to].presence ||
    #     (back || current_user.home_page) ||
    #     Kor.config['app.default_home_page'] ||
    #     root_path

    #   if params[:fragment].present?
    #     params[:fragment] = nil if params[:fragment].match('{{')
    #     r_to += "##{params[:fragment]}" if params[:fragment].present?
    #   end

    #   redirect_to r_to
    # end

end
