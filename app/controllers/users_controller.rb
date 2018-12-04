class UsersController < JsonController

  skip_before_filter :legal, :only => [:accept_terms]

  def accept_terms
    @user = current_user
    @user.terms_accepted = true

    if @user.save
      current_user.reload
      render_200 I18n.t('notices.terms_accepted')
    else
      @errors = @user.errors
      render_422
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
      render_422 I18n.t('errors.password_reset_failure')
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
      render_422 I18n.t('errors.login_attempts_reset_failure')
    end
  end

  def index
    params[:sort_by] ||= 'name'
    params[:sort_order] ||= 'ASC'

    @records = User.
      search(params[:terms]).
      order(params[:sort_by] => params[:sort_order])
    @total = @records.count
    @records = @records.pageit(page, per_page)
    render template: 'json/index'
  end

  def show
    @record = User.find(params[:id])
    render template: 'json/show'
  end

  # def new
  #   @user = User.new
  #   @user.groups << Credential.where(:name => Kor.settings['default_groups']).to_a
  # end
  
  def me
    @record = User.find(current_user.id)
    render template: 'json/show'
  end

  def update_me
    @record = User.find(current_user.id)

    if @record.update_attributes(me_params)
      render_200 I18n.t('objects.update_success', o: I18n.t('nouns.user.one'))
    else
      render_422 @record.errors
    end
  end

  def update
    # params[:user][:make_personal] ||= false
    @record = User.find(params[:id])

    if @record.update_attributes(user_params)
      render_200 I18n.t(
        'objects.update_success', o: I18n.t('nouns.user', count: 1)
      )
    else
      render_422 @record.errors
    end
  end

  def create
    @record = User.new(user_params)

    if @record.save
      UserMailer.account_created(@record).deliver_now
      render_200 I18n.t('objects.create_success',
        o: I18n.t('nouns.user', count: 1)
      )
    else
      render_422 @record.errors
    end
  end

  def destroy
    @record = User.find(params[:id])
    @record.destroy
    render_200 I18n.t('objects.destroy_success', o: I18n.t('nouns.user'))
  end
  

  private

    def user_params
      params.fetch(:user, {}).permit!
    end

    def me_params
      params.fetch(:user, {}).permit(
        :full_name, :name, :email, :password, :plain_password_confirmation,
        :locale, :home_page, :default_collection_id, :api_key, :lock_version
      )
    end
    
    def auth
      if ['accept_terms', 'me', 'update_me'].include?(action_name)
        require_non_guest
      else
        require_admin
      end
    end

end
