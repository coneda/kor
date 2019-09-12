# TODO: test this
class JsonController < BaseController
  rescue_from ActiveRecord::RecordNotFound, with: :render_record_not_found
  rescue_from ActiveRecord::StaleObjectError, with: :render_stale

  before_action :auth, :legal

  helper_method :inclusion, :page, :per_page, :sort

  layout false

  protected

    def name_for(record)
      case record
      when String then record
      when ApplicationRecord
        @record = record
        record.try(:display_name) ||
          record.try(:name) ||
          record.class.model_name.human
      else
        raise "don't know how to get name for #{record.inspect}"
      end
    end

    def render_created(record)
      @id = record.id
      render_200 I18n.t('objects.create_success', o: name_for(record))
    end

    def render_updated(record)
      render_200 I18n.t('objects.update_success', o: name_for(record))
    end

    def render_deleted(record)
      render_200 I18n.t('objects.destroy_success', o: name_for(record))
    end

    def render_200(message)
      @message = message
      render template: 'json/message', status: 200
    end

    def render_400(message)
      @message = message
      render template: 'json/message', status: 400
    end

    def render_401(message = nil)
      @message = message || I18n.t('messages.not_logged_in')
      render template: 'json/message', status: 401
    end

    def render_403(message = nil)
      @message = message || I18n.t('messages.access_denied')
      render template: 'json/message', status: 403
    end

    def render_record_not_found(exception)
      render_404 exception.message
    end

    def render_404(message = nil)
      @message = message || I18n.t('messages.not_found')
      render template: 'json/message', status: 404
    end

    def render_stale(exception)
      @message = I18n.t('messages.stale_update')
      render template: 'json/message', status: 422
    end

    def render_422(errors, message = nil)
      @errors = errors
      @message = message || I18n.t('activemodel.errors.template.header')
      render template: 'json/message', status: 422
    end

    def render_500(message = nil)
      @message = message || I18n.t('messages.exception_ocurred')
      render template: 'json/message', status: 500
    end

    def auth
    end

    def for_actions(*actions)
      if actions.include?(params[:action])
        yield
      end
    end

    def require_user
      render_401 unless current_user
    end

    def require_non_guest
      render_401 if !current_user || current_user.guest?
    end

    def require_role(role)
      if current_user
        render_403 unless current_user.send("#{role}?".to_sym)
      else
        render_401
      end
    end

    def require_admin
      require_role 'admin'
    end

    def require_relation_admin
      require_role 'relation_admin'
    end

    def require_authority_group_admin
      require_role 'authority_group_admin'
    end

    def require_kind_admin
      require_role 'kind_admin'
    end

    # redirects to the legal page if terms have not been accepted
    def legal
      if current_user && !current_user.guest? && !current_user.terms_accepted
        redirect_to :controller => 'static', :action => 'legal'
      end
    end

    def page
      [(params[:page] || 1).to_i, 1].max
    end

    def per_page
      return Kor.settings['max_results_per_request'] if params[:per_page] == 'max'

      @per_page = [
        (params[:per_page] || 10).to_i,
        Kor.settings['max_results_per_request']
      ].min
    end

    def sort
      if params[:sort] == 'random'
        return {
          column: 'random', direction: 'asc'
        }
      end

      return {
        column: params[:sort] || 'default',
        direction: params[:direction] || 'asc'
      }
    end

    def inclusion
      param_to_array(params[:include], ids: false)
    end

    def array_param(key, options = {})
      param_to_array params[key], options
    end

    def param_to_array(value, options = {})
      options.reverse_merge! ids: true

      case value
      when String
        results = value.split(',')
        options[:ids] ? results.map{ |v| v.to_i } : results
      when Integer then [value]
      when Array then value.map{ |v| param_to_array(v, options) }.flatten
      when nil then []
      else
        raise "unknown param format to convert to array: #{value}"
      end
    end

    def param_to_boolean(value)
      return true if ['true', true, 1, '1'].include?(value)

      nil
    end

    def param_to_time(value)
      Time.parse(value)
    rescue TypeError, ArgumentError => e
      nil
    end

    def zip_download(group, entities)
      if !entities.empty?
        zip_file = Kor::ZipFile.new("#{Rails.root}/tmp/download.zip",
          :user_id => current_user.id,
          :file_name => "#{group.name}.zip"
        )

        entities.each do |e|
          zip_file.add_entity e
        end

        if zip_file.background?
          zip_file.send_later :create_as_download
          render_200 I18n.t('messages.creating_zip_file')
        else
          download = zip_file.create_as_download
          redirect_to url_for(controller: 'downloads', action: 'show', uuid: download.uuid)
        end
      else
        render_200 I18n.t('messages.no_entities_in_group')
      end
    end
end
