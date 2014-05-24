class ConfigController < ApplicationController
  layout 'normal_small', :except => 'menu'

  def menu
    session[:expand_config_menu] = params[:folding] == 'expand'
    render :nothing => true
  end
  
  def general
    @check = Kor::Config::Check.new(Kor.config)
    @help_sections = [
      'component_search.component_search',
      'entities.index',
      'entities.multi_upload',
      'authentication.form',
      'users.edit_self',
      'entities.gallery',
      'authority_group_categories.index',
      'user_groups.index',
      'tools.clipboard'
    ]
  end
  
  def save_general
    config = Kor::Config.new(Kor.app_config_file)
    config.update(params[:config])
    config.store(Kor.app_config_file)
    Kor.config true
    system "touch #{Rails.root}/tmp/restart.txt"
    flash[:message] = I18n.t('messages.app_settings_stored')
    redirect_to :action => 'general'
  end
  
  private
    def generally_authorized
      current_user.admin?
    end

end
