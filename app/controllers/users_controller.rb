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
      UserMailer.reset_password(@user).deliver_now
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
  
    @users = User.
      search(params[:search_string]).
      order("#{params[:sort_by]} #{params[:sort_order]}").
      paginate(:page => params[:page], :per_page => 10)

    respond_to do |format|
      format.html {render :layout => 'wide'}
      format.json do
        render :json => @users.to_json(:except => [:activation_hash, :password, :api_key])
      end
    end
  end

  def show
    redirect_to edit_user_path(params[:id])
  end

  def new
    @user = User.new
    @user.groups << Credential.where(:name => Kor.config['auth.default_groups']).to_a
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

    if @user.update_attributes(self_user_params)
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

    if @user.update_attributes(user_params)
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
    @user = User.new(user_params)
    
    if @user.save
      flash[:notice] = I18n.t( 'objects.create_success', :o => I18n.t('nouns.user', :count => 1) )
      UserMailer.account_created(@user).deliver_now
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

    def user_params
      params.require(:user).permit!
    end

    def self_user_params
      params.require(:user).permit(
        :full_name, :name, :email, :password, :password_confirmation, :locale,
        :home_page, :default_collection_id, :api_key
      )
    end
    
    def generally_authorized?
      current_user.admin?
    end



end
