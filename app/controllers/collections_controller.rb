class CollectionsController < ApplicationController
  layout 'normal_small'
  
  def index
    @collections = Collection.non_personal.all
  end

  def show
    @collection = Collection.find(params[:id])
  end

  def new
    @collection = Collection.new
  end
  
  def edit_personal
    @collection = Collection.joins(:owner).first
  end
  
  def edit_merge
    @collection = Collection.find(params[:id])
  end
  
  def merge
    @collection = Collection.find(params[:id])
    target = Collection.find(params[:collection_id])
    
    if authorized?(:delete, @collection) && authorized?(:create, target)
      Entity.update_all "collection_id = #{target.id}", ["collection_id = ?", @collection.id]
      flash[:notice] = I18n.t('messages.entities_moved_to_collection', :o => target.name)
      redirect_to collections_path
    else
      redirect_to denied_page
    end
  end
  
  def edit
    @collection = Collection.find(params[:id])
  end

  def create
    @collection = Collection.new(collection_params)

    if @collection.save
      flash[:notice] = I18n.t('objects.create_success', :o => @collection.name)
      redirect_to collections_path
    else
      render :action => "new"
    end
  end

  def update
    @collection = Collection.find(params[:id])

    if @collection.update_attributes(collection_params)
      flash[:notice] = I18n.t('objects.update_success', :o => @collection.name)
      redirect_to collections_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @collection = Collection.find(params[:id])
    
    if @collection.entities.count == 0
      @collection.destroy
    else
      flash[:error] = I18n.t('errors.collection_not_empty_on_delete', :name => @collection.name)
    end
    
    redirect_to(collections_path)
  end
  
  protected

    def generally_authorized?
      current_user.admin?
    end

    def collection_params
      params.require(:collection).permit!
    end
    
end
