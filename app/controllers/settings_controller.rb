class SettingsController < JsonController
  skip_before_filter :auth, only: 'show'

  def show
    @settings = Kor.settings
    render json: @settings.as_json
  end

  def update
    @settings = Kor::Settings.new

    if @settings.update settings_params
      human_name = I18n.t('activerecord.models.setting', count: :other)
      render_200 I18n.t('objects.update_success', o: human_name)
    else
      render_422 @settings.errors
    end
  end

  protected

    def auth
      for_actions 'update' do
        require_admin
      end
    end

    def settings_params
      params.fetch(:settings, {}).permit!
    end

end
