class UsersController < ApplicationController
  layout 'normal_small'
  skip_before_filter :legal, :only => [:accept_terms]
  skip_before_filter :authorization, :only => [:edit_self, :update_self, :accept_terms]

  def accept_terms
    @user = current_user
    @user.terms_accepted = true

    if @user.save
      current_user.reload
      flash[:notice] = I18n.t('notices.terms_accepted')
      redirect_to root_url
    end
  end

  def reset_password
    @user = User.without_predefined.find(params[:id])
    @user.reset_password

    if @user.save
      flash[:notice] = I18n.t("messages.password_reset", :username => @user.display_name)
      UserMailer.reset_password(@user).deliver
    else
      flash[:error] = I18n.t('errors.password_reset_failure')
    end
    
    redirect_to back_save
  end
  
  def reset_login_attempts
    @user = User.find(params[:id])
    @user.login_attempts = []

    if @user.save
      flash[:notice] = I18n.t("messages.login_attempts_reset", :username => @user.display_name)
    else
      flash[:error] = I18n.t('errors.login_attempts_reset_failure')
    end
    
    redirect_to back_save
  end

  def index
    params[:sort_by] ||= 'name'
    params[:sort_order] ||= 'ASC'
  
    @users = User.without_admin.search(params[:search_string]).paginate(
      :order => "#{params[:sort_by]} #{params[:sort_order]}",
      :page => params[:page], :per_page => 10
    )
    
    render :layout => 'wide'
  end

  def show
    redirect_to edit_user_path(params[:id])
  end

  def new
    @user = User.new
    @user.groups << Credential.find_all_by_name( Kor.config['auth.default_groups'] )
  end
  
  def edit_self
    if current_user.guest?
      redirect_to denied_path
    else
      @user = User.find(current_user.id)
    end
  end

  def update_self
    @user = User.find(current_user.id)
    
    if @user.update_attributes(params[:user])
      flash[:notice] = I18n.t( 'objects.update_success', :o => I18n.t('nouns.user', :count => 1) )
      redirect_to root_path
    else
      render :action => "edit_self"
    end
  rescue ActiveRecord::StaleObjectError
    flash[:error] = I18n.t('activerecord.errors.messages.stale_user_update')
    render :action => 'edit_self'
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    params[:user][:make_personal] ||= false
  
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = I18n.t( 'objects.update_success', :o => I18n.t('nouns.user', :count => 1) )
      redirect_to users_path
    else
      render :action => "edit"
    end
  rescue ActiveRecord::StaleObjectError
    flash[:error] = I18n.t('activerecord.errors.messages.stale_user_update')
    render :action => 'edit'
  end

  def create
    @user = User.new(params[:user])
    
    if @user.save
      flash[:notice] = I18n.t( 'objects.create_success', :o => I18n.t('nouns.user', :count => 1) )
      UserMailer.account_created(@user).deliver
      redirect_to users_path
    else
      render :action => "new"
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    redirect_to users_path
  end
  
  private
    def generally_authorized?
      current_user.user_admin?
    end

end
