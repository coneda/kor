# TODO: remove non-json responses
class KindsController < ApplicationController
  layout 'normal_small'

  def index
    params[:include] = param_to_array(params[:include], ids: false)

    @kinds = Kind.all

    respond_to do |format|
      format.html {render :layout => 'wide'}
      format.json
    end
  end

  def show
    params[:include] = param_to_array(params[:include], ids: false)

    @kind = Kind.find(params[:id])
  end

  def new
    @kind = Kind.new
  end

  def edit
    @kind = Kind.find(params[:id])
  end
  
  def create
    @kind = Kind.new(kind_params)

    respond_to do |format|
      format.html do
        if @kind.save
          flash[:notice] = I18n.t( 'objects.create_success', :o => Kind.model_name.human )
          redirect_to :action => 'index'
        else
          render :action => "new"
        end
      end
      format.json do
        if @kind.save
          @message = I18n.t( 'objects.create_success', :o => Kind.model_name.human )
          render action: 'save'
        else
          render action: 'save', status: 406
        end
      end
    end
  end

  def update
    @kind = Kind.find(params[:id])

    params[:kind] ||= {}
    params[:kind][:settings] ||= {}
    params[:kind][:settings][:tagging] ||= false
    
    respond_to do |format|
      format.html do
        if @kind.update_attributes(kind_params)
          flash[:notice] = I18n.t('objects.update_success', o: Kind.model_name.human )
          redirect_to action: 'index'
        else
          render action: 'edit'
        end
      end
      format.json do
        if @kind.update_attributes(kind_params)
          @message = I18n.t('objects.update_success', o: Kind.model_name.human)
          render action: 'save'
        else
          render action: 'save', status: 406
        end
      end
    end
  end

  def destroy
    @kind = Kind.find(params[:id])
    
    respond_to do |format|
      format.html do
        unless @kind == Kind.medium_kind
          @kind.destroy
          redirect_to(kinds_url)
        else
          redirect_to denied_path
        end
      end
      format.json do
        if @kind == Kind.medium_kind
          @message = "the medium kind can't be deleted"
          render action: 'save', status: 403
        elsif @kind.children.present?
          @message = "kinds with children can't be deleted"
          render action: 'save', status: 403
        else
          @kind.destroy
          @message = I18n.t( 'objects.destroy_success', :o => Kind.model_name.human)
          render action: 'save'
        end
      end
    end
  end
  
  
  protected
    
    def kind_params
      params.require(:kind).permit(
        :name, :plural_name, :description,
        :tagging, :name_label, :dating_label, :distinct_name_label, :url,
        :abstract, parent_ids: [], child_ids: [],
      )
    end

    def generally_authorized?
      if action_name == 'index' || action_name == 'show'
        true
      else
        current_user.kind_admin?
      end
    end

end
