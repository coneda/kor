class AuthorityGroupCategoriesController < ApplicationController
  layout 'small_normal'
  
  skip_before_filter :authorization, :only => [:index, :show]
  
  def index
    @authority_group_categories = AuthorityGroupCategory.roots
  end

  def show
    @authority_group_category = AuthorityGroupCategory.find(params[:id])
  end

  def new
    @authority_group_category = AuthorityGroupCategory.new
    render :layout => 'normal_small'
  end

  def edit
    @authority_group_category = AuthorityGroupCategory.find(params[:id])
    render :layout => 'normal_small'
  end

  def create
    @authority_group_category = AuthorityGroupCategory.new(params[:authority_group_category])

    if @authority_group_category.save
      flash[:notice] = I18n.t( 'objects.create_success', :o => @authority_group_category.name )
      unless params[:parent_id].blank?
        @authority_group_category.move_to_child_of(AuthorityGroupCategory.find(params[:parent_id]))
        @authority_group_category.save
        redirect_to authority_group_category_path(params[:parent_id])
      else
        redirect_to :action => 'index'
      end
    else
      render :action => "new", :layout => 'normal_small'
    end
  end

  def update
    @authority_group_category = AuthorityGroupCategory.find(params[:id])

    if @authority_group_category.update_attributes(params[:authority_group_category])
      flash[:notice] = I18n.t( 'objects.update_success', :o => @authority_group_category.name )
      unless @authority_group_category.parent_id.blank?
        redirect_to @authority_group_category.parent
      else
        redirect_to :action => 'index'
      end
    else
      render :action => "edit", :layout => 'normal_small'
    end
  end

  def destroy
    @authority_group_category = AuthorityGroupCategory.find(params[:id])
    @authority_group_category.destroy
    
    redirect_to(@authority_group_category.parent || authority_group_categories_path)
  end
  
  protected
    def generally_authorized?
      current_user.authority_group_admin?
    end
  
end
