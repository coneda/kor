require "resolv"

class AuthenticationController < ApplicationController
  layout 'small_normal'
  skip_before_filter :authentication, :authorization, :legal
  
  def form
    if user = Kor::Auth.env_login(request.env)
      create_session(user)
      redirect_after_login
    else
      render :layout => 'small_normal_bare'
    end
  end
  
  def password_forgotten
    render :layout => 'small_normal_bare'
  end
  
  def personal_password_reset
    @user = User.find_by_email(params['email'])
    
    if @user && !@user.admin?
      flash[:notice] = I18n.t('notices.personal_password_reset_success')
      @user.reset_password
      @user.save
      UserMailer.reset_password(@user).deliver_now
    else
      flash[:error] = I18n.t('errors.personal_password_reset_mail_not_found')
    end
    
    redirect_to :action => 'form'
  end
  
  # TODO: return status "403 Forbidden" if authentication fails
  def login
    account_without_password = User.find_by_name(params[:username])
    if account_without_password && account_without_password.too_many_login_attempts?
      flash[:error] = I18n.t('errors.too_many_login_attempts')
      redirect_to :action => 'form'
    else
      account = Kor::Auth.login(params[:username], params[:password])

      if account
        account.update_attributes(:login_attempts => [])

        if account.expires_at && (account.expires_at <= Time.now)
          respond_to do |format|
            format.html do
              flash[:error] = I18n.t("errors.account_expired")
              redirect_to action: "form"
            end
            format.json do
              render(
                json: {'message' => I18n.t("errors.account_expired")},
                status: 400
              )
            end
          end
        elsif !account.active
          reset_session

          respond_to do |format|
            format.html do
              flash[:error] = I18n.t("errors.account_inactive")
              redirect_to action: 'form'
            end
            format.json do
              render(
                json: {'message' => I18n.t("errors.account_inactive")},
                status: 400
              )
            end
          end
        else
          account.fix_cryptography(params[:password])
          create_session(account)

          redirect_after_login
        end
      else
        if account_without_password
          account_without_password.add_login_attempt
          account_without_password.save
        end
        # reset_session cant be done here because of http://railsforum.com/viewtopic.php?id=1611 (dead link)
        # reset_session

        respond_to do |format|
          format.html do
            flash[:error] = I18n.t("errors.user_or_pass_refused")
            redirect_to :action => "form"
          end
          format.json do
            render(
              json: {'message' => I18n.t("errors.user_or_pass_refused")},
              status: 400
            )
          end
        end
      end
    end
  end
  
  def logout
    reset_session
    flash[:notice] = I18n.t("notices.logged_out")    
    redirect_to root_path
  end
  
  def denied
    respond_to do |format|
      format.html do
        if !current_user
          redirect_to :controller => 'authentication', :action => 'form'
        else
          render :layout => 'normal_small'
        end
      end
      format.json do
        render :json => {:message => I18n.t('notices.access_denied')}, :status => 403
      end
    end
  end

  private

    def create_session(user)
      session[:expires_at] = Kor.session_expiry_time
      session[:user_id] = user.id
      user.update_attributes(last_login: Time.now)
    end

    def redirect_after_login
      respond_to do |format|
        format.html do
          r_to = (back || current_user.home_page) || Kor.config['app.default_home_page'] || root_path

          if params[:fragment].present?
            params[:fragment] = nil if params[:fragment].match('{{')
            r_to += "##{params[:fragment]}" if params[:fragment].present?
          end

          redirect_to r_to
        end
        format.json do
          redirect_to '/api/1.0/info'
        end
      end
    end

    # TODO: still needed?
    def remote_ip_with_name
      "#{request.ip} (#{Resolv.getname(request.ip)})"
    rescue Resolv::ResolvError => e
      request.ip
    end

end
