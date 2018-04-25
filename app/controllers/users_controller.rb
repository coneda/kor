class UsersController < JsonController

  skip_before_filter :legal, :only => [:accept_terms]
  skip_before_filter :authorization, :only => [:update_self, :accept_terms]

  def accept_terms
    @user = current_user
    @user.terms_accepted = true

    if @user.save
      current_user.reload
      render_200 I18n.t('notices.terms_accepted')
    else
      @errors = @user.errors
      render_406
    end
  end

  def reset_password
    @user = User.without_predefined.find(params[:id])
    @user.reset_password

    if @user.save
      UserMailer.reset_password(@user).deliver_now
      render_200 I18n.t("messages.password_reset", username: @user.display_name)
    else
      @errors = @user.errors
      render_406 I18n.t('errors.password_reset_failure')
    end
  end
  
  def reset_login_attempts
    @user = User.find(params[:id])
    @user.login_attempts = []

    if @user.save
      render_200 I18n.t("messages.login_attempts_reset", 
        username: @user.display_name
      )
    else
      @errors = @user.errors
      render_406 I18n.t('errors.login_attempts_reset_failure')
    end
  end

  def index
    params[:sort_by] ||= 'name'
    params[:sort_order] ||= 'ASC'

    @per_page = params[:per_page] || 10
    @page = params[:page] || 1
    @records = User.
      search(params[:search_string]).
      order(params[:sort_by] => params[:sort_order])
    @total = @records.count
    @records = @records.pageit(@page, @per_page)
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
    @user.groups << Credential.where(:name => Kor.config['auth.default_groups']).to_a
  end
  
  def edit_self
    if current_user.guest?
      render_403
    else
      @user = User.find(current_user.id)
    end
  end

  def update_self
    @user = User.find(current_user.id)

    if @user.update_attributes(self_user_params)
      render_200 I18n.t( 'objects.update_success', o: I18n.t('nouns.user'))
    else
      render_406 @user.errors
    end
  end

  def update
    params[:user][:make_personal] ||= false
    @user = User.find(params[:id])

    if @user.update_attributes(user_params)
      render_200 I18n.t(
        'objects.update_success', o: I18n.t('nouns.user', count: 1)
      )
    else
      render_406 @user.errors
    end
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      UserMailer.account_created(@user).deliver_now
      render_200 I18n.t('objects.create_success',
        o: I18n.t('nouns.user', count: 1)
      )
    else
      render_406 @user.errors
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    render_200 I18n.t('objects.destroy_success',
      o: I18n.t('nouns.user', count: 1)
    )
  end
  

  private

    def user_params
      params.require(:user).permit!
    end

    def self_user_params
      params.require(:user).permit(
        :full_name, :name, :email, :password, :plain_password_confirmation,
        :locale, :home_page, :default_collection_id, :api_key
      )
    end
    
    def generally_authorized?
      current_user.admin?
    end

end
