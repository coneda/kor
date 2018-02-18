# TODO: test this
class JsonController < BaseController

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  before_filter :authentication, :role_auth, :legal


  protected

    def render_200(message)
      @message = message
      render action: '../layouts/message', status: 200
    end

    def render_400(message)
      @message = message
      render action: '../layouts/message', status: 400
    end 

    def render_403(message = nil)
      @message = message || I18n.t('notices.access_denied')
      render action: '../layouts/message', status: 403
    end

    def render_404(message = nil)
      @message = message || I18n.t('messages.not_found')
      render action: '../layouts/message', status: 404
    end

    def render_406(errors, message = nil)
      @errors = errors
      @message = message || I18n.t('activemodel.errors.template.header')
      render action: '../layouts/message', status: 406
    end

    def render_500(message = nil)
      @message = message || I18n.t('errors.exception_ocurred')
      render action: '../layouts/message', status: 500
    end

    # deny service if there is no guest and when we are unauthenticated
    def authentication
      if !current_user
        render_403
      end
    end

    # TODO: make this a whitelist?
    def role_authorized?
      true
    end

    def role_auth
      render_403 unless role_authorized?
    end

    # redirects to the legal page if terms have not been accepted
    def legal
      if current_user && !current_user.guest? && !current_user.terms_accepted
        redirect_to :controller => 'static', :action => 'legal'
      end
    end

    # TODO: get config values instead of 10 and 100
    def pagination
      @page = [(params[:page] || 1).to_i, 1].max
      @per_page = [
        (params[:per_page] || 10).to_i,
        100.to_i
      ].min
    end

    def param_to_array(value, options = {})
      options.reverse_merge! ids: true

      case value
        when String
          results = value.split(',')
          options[:ids] ? results.map{|v| v.to_i} : results
        when Integer then [value]
        when Array then value.map{|v| param_to_array(v, options)}.flatten
        when nil then []
        else
          raise "unknown param format to convert to array: #{value}"
      end
    end

end