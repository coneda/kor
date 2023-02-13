# TODO: test this
class JsonController < BaseController
  rescue_from ActiveRecord::RecordNotFound, with: :render_record_not_found
  rescue_from ActiveRecord::StaleObjectError, with: :render_stale
  rescue_from Kor::Exception, with: :render_kor_exception

  before_action :auth, :legal

  helper_method :inclusion, :related_inclusion, :page, :per_page, :sort

  layout false

  protected

    def name_for(record)
      case record
      when String then record
      when Generator then record.name
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

    def render_400(message, opts = {})
      @opts = opts
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
      respond_to do |format|
        format.json do
          render_404 I18n.t('messages.not_found')
        end
        format.any do
          render(
            plain: I18n.t('messages.not_found'),
            content_type: 'text/plain',
            status: 404
          )
        end
      end
    end

    def render_404(message = nil)
      @message = message || I18n.t('messages.not_found')
      render template: 'json/message', status: 404
    end

    def render_stale(exception)
      @message = I18n.t('messages.stale_update')
      render template: 'json/message', status: 422
    end

    def render_kor_exception(exception)
      @message = exception.message
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

    def legal
      if current_user && !current_user.guest? && !current_user.terms_accepted
        @code = 'terms-not-accepted'
        render_403 I18n.t('messages.accept_terms_prompt')
      end
    end

    def page
      [(params[:page] || 1).to_i, 1].max
    end

    def cap_per_page
      true
    end

    def per_page
      if params[:per_page] == 'max'
        return 'max' unless cap_per_page

        return Kor.settings['max_results_per_request']
      end

      from_param = (params[:per_page] || 10).to_i
      from_param = 10 if from_param < 1

      @per_page = [
        from_param,
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

    def related_inclusion
      param_to_array(params[:related_include], ids: false)
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
      if entities.empty?
        render_200 I18n.t('messages.no_entities_in_group')
        return
      end

      args = [
        current_user.id,
        group.class.name,
        group.id,
        entities.pluck(:id)
      ]

      zip_file = Kor::ZipFile.create(*args)

      if zip_file.background?
        GenericJob.perform_later('constant', 'Kor::ZipFile', 'create!', *args)
        flash[:notice] = I18n.t('messages.creating_zip_file')
        redirect_to root_path(anchor: group_path(group))
      else
        download = zip_file.build
        redirect_to url_for(controller: 'downloads', action: 'show', uuid: download.uuid)
      end
    end

    def group_path(group)
      case group
      when UserGroup then "/groups/user/#{group.id}"
      when AuthorityGroup then "/groups/admin/#{group.id}"
      end
    end
end
