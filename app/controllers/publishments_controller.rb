class PublishmentsController < JsonController
  skip_before_filter :authentication, :authorization, :only => :show
  # layout 'normal_small', :only => [ :new, :edit, :show, :create ]

  def extend
    @publishment = Publishment.owned_by(current_user).find(params[:id])
    @publishment.valid_until = Kor.publishment_expiry_time

    if @publishment.save
      render_200 I18n.t('objects.extend_success',
        :o => @publishment.name,
        :until => I18n.l(@publishment.valid_until)
      )
    else
      render_406 I18n.t('objects.extend_failure', :o => @publishment.name)
    end
  end

  def index
    @records = Publishment.owned_by(current_user)
    @total = @records.count
    render template: 'json/index'
  end

  def show
    @publishment = Publishment.find_by(user_id: params[:user_id], uuid: params[:uuid])
    @user_group = @publishment.user_group

    if @publishment.valid_until < Time.now
      render_403 I18n.t('errors.publishment_expired')
    end
  end

  def create
    @publishment = Publishment.owned_by(current_user).build(publishment_params)

    if @publishment.save
      render_200 I18n.t('objects.create_success', :o => @publishment.name)
    else
      render_406 @publishment.errors
    end
  end

  def destroy
    # TODO: ensure this can only be done be the owner
    @publishment = Publishment.find(params[:id])
    @publishment.destroy
    render_200 I18n.t('objects.destroy_success', :o => @publishment.name)
  end
  
  protected

    def publishment_params
      params.fetch(:publishment, {}).permit(:user_group_id, :name)
    end

    def generally_authorized?
      current_user && current_user != User.guest
    end

end
