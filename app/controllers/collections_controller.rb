class CollectionsController < JsonController
  skip_before_filter :auth, only: [:index]

  def index
    if current_user.admin?
      @records = Collection.all
    else
      @records = Kor::Auth.authorized_collections(current_user)
    end

    @total = @records.count
    @records = @records.pageit(page, per_page)
    render 'json/index'
  end

  def show
    if current_user.admin?
      @record = Collection.find(params[:id])
    else
      @record = Kor::Auth.authorized_collections(current_user).find(params[:id])
    end
    render 'json/show'
  end

  def create
    @record = Collection.new(collection_params)

    if @record.save
      render_created @record
    else
      render_422 @record.errors
    end
  end

  def update
    @record = Collection.find(params[:id])

    if @record.update_attributes(collection_params)
      render_updated @record
    else
      render_422 @record.errors
    end
  end

  def destroy
    @record = Collection.find(params[:id])

    if @record.entities.count == 0
      @record.destroy
      render_deleted @record
    else
      render_400 I18n.t('errors.collection_not_empty_on_delete', name: @record.name)
    end
  end

  def merge
    @record = Collection.find(params[:id])
    target = Collection.find(params[:collection_id])

    if allowed_to?(:delete, @record) && allowed_to?(:create, target)
      Entity.where(collection_id: @record.id).update_all collection_id: target.id
      render_200 I18n.t('messages.entities_moved_to_collection', o: target.name)
    else
      render_403
    end
  end

  protected

    def auth
      require_admin
    end

    def collection_params
      params.require(:collection).permit!
    end
end
