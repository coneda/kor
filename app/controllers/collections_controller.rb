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

  # def new
  #   @collection = Collection.new
  # end
  
  # TODO: check if this can actually work and if its save. Would be best to
  # ditch the feature
  # def edit_personal
  #   @collection = Collection.joins(:owner).first
  # end
  
  def create
    @record = Collection.new(collection_params)

    if @record.save
      render_200 I18n.t('objects.create_success', o: @record.name)
    else
      render_406 @record.errors
    end
  end

  def update
    @record = Collection.find(params[:id])

    if @record.update_attributes(collection_params)
      render_200 I18n.t('objects.update_success', o: @record.name)
    else
      render_406 @record.errors
    end
  end

  def destroy
    @record = Collection.find(params[:id])
    
    if @record.entities.count == 0
      @record.destroy
      render_200 I18n.t('objects.destroy_success', o: @record.name)
    else
      render_400 I18n.t('errors.collection_not_empty_on_delete', name: @record.name)
    end
  end

  def merge
    @record = Collection.find(params[:id])
    target = Collection.find(params[:collection_id])
    
    if authorized?(:delete, @record) && authorized?(:create, target)
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
