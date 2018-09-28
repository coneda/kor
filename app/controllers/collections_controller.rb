# TODO: test this
class CollectionsController < JsonController

  skip_before_filter :auth, only: [:index]

  def index
    if current_user.admin?
      @records = Collection.non_personal
    else
      @records = Kor::Auth.authorized_collections(current_user)
    end
    
    @total = @records.count
    @records = @records.pageit(page, per_page)
  end

  def show
    @collection = Collection.find(params[:id])
  end

  # def new
  #   @collection = Collection.new
  # end
  
  # TODO: check if this can actually work and if its save. Would be best to
  # ditch the feature
  def edit_personal
    @collection = Collection.joins(:owner).first
  end
  
  # TODO: test this
  def merge
    @collection = Collection.find(params[:id])
    target = Collection.find(params[:collection_id])
    
    if authorized?(:delete, @collection) && authorized?(:create, target)
      Entity.where(collection_id: @collection.id).update_all collection_id: target.id
      render_200 I18n.t('messages.entities_moved_to_collection', o: target.name)
    else
      render_403
    end
  end
  
  def create
    @collection = Collection.new(collection_params)

    if @collection.save
      render_200 I18n.t('objects.create_success', o: @collection.name)
    else
      render_406 @collection.errors
    end
  end

  def update
    @collection = Collection.find(params[:id])

    if @collection.update_attributes(collection_params)
      render_200 I18n.t('objects.update_success', o: @collection.name)
    else
      render_406 @collection.errors
    end
  end

  def destroy
    @collection = Collection.find(params[:id])
    
    if @collection.entities.count == 0
      @collection.destroy
      render_200 I18n.t('objects.destroy_success', o: @collection.name)
    else
      render_400 I18n.t('errors.collection_not_empty_on_delete', name: @collection.name)
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
