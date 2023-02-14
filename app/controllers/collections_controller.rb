class CollectionsController < JsonController
  skip_before_action :auth, only: [:index]
  skip_before_action :legal, only: [:index]

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
    # TODO: the check shouldn't be necessary or might be even too much
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

    if @record.update(collection_params)
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
      render_400 I18n.t('messages.collection_not_empty_on_delete', name: @record.name)
    end
  end

  def merge
    @record = Collection.find(params[:id])
    target = Collection.find(params[:collection_id])

    # TODO: This shouldn't be necessary or might even be too mutch: collection
    # admins only are allowed here
    if allowed_to?(:delete, @record) && allowed_to?(:create, target)
      Entity.
        where(collection_id: @record.id).
        update_all(['collection_id = ?', target.id])
      render_200 I18n.t('messages.collections_merged', o: target.name)
    else
      render_403
    end
  end

  def entities
    @record = Collection.find(params[:id])
    @entities = Entity.find(params[:entity_ids])
    from_collection_ids = @entities.pluck(:collection_id).uniq

    allowed = (
      allowed_to?(:delete, from_collection_ids) &&
      allowed_to?(:create, @record)
    )

    if allowed
      @entities.each do |entity|
        entity.update collection_id: @record.id
      end
      render_200 I18n.t('messages.entities_moved_to_collection', o: @record.name)
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
