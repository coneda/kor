class PublishmentsController < ApplicationController
  skip_before_filter :authentication, :authorization, :only => :show
  layout 'normal_small', :only => [ :new, :edit, :show, :create ]

  def extend
    @publishment = Publishment.owned_by(current_user).find(params[:id])
    @publishment.valid_until = Kor.publishment_expiry_time

    if @publishment.save
      flash[:notice] = I18n.t('objects.extend_success',
        :o => @publishment.name,
        :until => I18n.l(@publishment.valid_until) )
    else
      flash[:error] = I18n.t('objects.extend_failure', :o => @publishment.name)
    end
    redirect_to :action => 'index'
  end

  def index
    @publishments = Publishment.owned_by(current_user)
    render :layout => 'wide'
  end

  def show
    @publishment = Publishment.owned_by(User.find(params[:user_id])).find_by_uuid(params[:uuid])
    @user_group = @publishment.user_group

    if @publishment.valid_until < Time.now
      flash[:error] = I18n.t('errors.publishment_expired')
      redirect_to root_path
    else
      render :layout => 'wide'
    end
  end

  def new
    @publishment = Publishment.owned_by(current_user).build(publishment_params)
  end

  def create
    @publishment = Publishment.owned_by(current_user).build(publishment_params)

    if @publishment.save
      flash[:notice] = I18n.t('objects.create_success', :o => @publishment.name )
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def destroy
    @publishment = Publishment.find(params[:id])
    @publishment.destroy

    flash[:notice] = I18n.t('objects.destroy_success', :o => @publishment.name )
    redirect_to :action => 'index'
  end
  
  protected

    def publishment_params
      params.require(:publishments).permit(:user_group_id, :name)
    end

    def generally_authorized?
      current_user && current_user != User.guest
    end
  
end
