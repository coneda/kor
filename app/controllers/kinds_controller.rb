# TODO: remove non-json responses
class KindsController < ApplicationController

  skip_before_filter :authentication, :authorization, only: ['index', 'show']

  def index
    params[:include] = param_to_array(params[:include], ids: false)

    @kinds = Kind.all
  end

  def show
    @kind = Kind.find(params[:id])
  end

  def create
    @kind = Kind.new(kind_params)

    if @kind.save
      @message = I18n.t( 'objects.create_success', :o => Kind.model_name.human )
      render action: 'save'
    else
      render action: 'save', status: 406
    end
  end

  def update
    @kind = Kind.find(params[:id])

    params[:kind] ||= {}
    params[:kind][:settings] ||= {}
    params[:kind][:settings][:tagging] ||= false
    
    if @kind.update_attributes(kind_params)
      @message = I18n.t('objects.update_success', o: Kind.model_name.human)
      render action: 'save'
    else
      render action: 'save', status: 406
    end
  end

  def destroy
    @kind = Kind.find(params[:id])
    
    if @kind == Kind.medium_kind
      @message = "the medium kind can't be deleted"
      render action: 'save', status: 406
    elsif @kind.children.present?
      @message = "kinds with children can't be deleted"
      render action: 'save', status: 406
    else
      @kind.destroy
      @message = I18n.t( 'objects.destroy_success', :o => Kind.model_name.human)
      render action: 'save'
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
      current_user.kind_admin?
    end

end
