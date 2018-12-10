class PublishmentsController < JsonController
  skip_before_filter :auth, only: 'show'

  def extend_publishment
    @publishment = Publishment.owned_by(current_user).find(params[:id])
    @publishment.valid_until = Kor.publishment_expiry_time

    if @publishment.save
      render_200 I18n.t('objects.extend_success',
        :o => @publishment.name,
        :until => I18n.l(@publishment.valid_until)
      )
    else
      render_422 I18n.t('objects.extend_failure', :o => @publishment.name)
    end
  end

  def index
    @records = Publishment.owned_by(current_user)
    @total = @records.count
    render template: 'json/index'
  end

  def show
    @publishment = Publishment.find_by!(
      user_id: params[:user_id],
      uuid: params[:uuid]
    )
    @user_group = @publishment.user_group

    if @publishment.valid_until < Time.now
      render_404 I18n.t('messages.publishment_expired')
    end
  end

  def create
    @publishment = Publishment.owned_by(current_user).build(publishment_params)

    if @publishment.save
      render_created @publishment
    else
      render_422 @publishment.errors
    end
  end

  def destroy
    # TODO: ensure this can only be done be the owner
    @publishment = Publishment.find(params[:id])
    @publishment.destroy
    render_deleted @publishment
  end

  protected

    def publishment_params
      params.fetch(:publishment, {}).permit(:user_group_id, :name)
    end

    def auth
      require_non_guest
    end
end
