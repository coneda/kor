module MediaHelper

  def kor_medium(entity, options = {})
    options.reverse_merge!(
      :link => true,
      :style => :thumbnail,
      :buttons => true,
      :wrap => true,
      :use_special => false
    )

    entity = entity.class == Entity ? entity : entity.entity
    medium = entity.medium

    options[:presenter] ||= if options[:use_special]
      select_presenter(medium.content_type)
    else
      select_presenter('image')
    end

    options[:url] ||= web_path(:anchor => entity_path(entity))

    result = options[:presenter].call(entity, options)

    id = "kor_medium_frame_#{entity.id}"
    button_bar = if options[:buttons] && allowed_to?(:edit)
      content_tag 'span', :class => 'button_bar', :style => 'display: none' do
        in_clipboard = (session[:clipboard] || []).include?(entity.id)

        link_to(kor_command_image('target_hit'), '/', :style => (in_clipboard ? nil : 'display: none'), :class => 'marked') +
        link_to(kor_command_image('target'), '/', :style => (in_clipboard ? 'display: none' : nil), :class => 'unmarked')
      end
    else
      ""
    end

    if options[:wrap]
      content_tag('div', result + button_bar, :class => 'kor_medium_frame', :id => id) + content_tag('div', '', :style => 'clear: both')
    else
      result
    end
  end

  def formats_for(entity)
    if entity.is_medium?
      result = viewer_link(entity)

      dl_links = []

      if authorized?(:download_originals, entity.collection) || (!entity.medium.content_type.match(/\image/) && authorized?(:view, entity.collection))
         dl_links << (link_to I18n.t("nouns.original"), download_medium_path(:id => entity.medium_id, :style => :original))
      end

      if !current_user.guest? && entity.medium.content_type.match(/^image/)
        dl_links << download_link(entity)
      end

      dl_links << link_to(I18n.t('nouns.metadata'), metadata_entity_path(@entity))

      result += "<br>#{I18n.t('verbs.download')}:<br>&nbsp;&nbsp; ".html_safe + dl_links.join(' | ').html_safe
      result.html_safe
    end
  end

  def download_link(entity)
    link_to( I18n.t('nouns.enlargement'), download_medium_path(:id => @entity.medium.id, :style => :normal) )
  end

  def viewer_link(entity)
    medium = entity.medium

    if medium
      if medium.content_type.match(/^image\//)
        link_to(I18n.t('verbs.enlarge'), view_medium_path(medium.id)) + ' | ' +
        link_to(I18n.t('verbs.maximize'), maximize_medium_path(medium))
      else
        ""
      end
    end
  end

  private
    def select_presenter(content_type)
      presenters[content_type] || presenters[content_type.split('/').first] || presenters[:unknown]
    end

    def media_dummy_path(content_type)
      "/content_types/#{content_type}.gif"
    end

    def presenters
      result = {}

      result[:unknown] = Proc.new do |entity, options|
        image_tag media_dummy_path(entity.medium.content_type)
      end

      result['image'] = Proc.new do |entity, options|
        image_url = entity.medium.url(options[:style])
        if options[:no_link] || !options[:link]
          image_tag image_url, :class => 'kor_medium'
        else
          link_to image_tag(image_url, :class => 'kor_medium'), options[:url]
        end
      end

      result['application/x-shockwave-flash'] = Proc.new do |entity, options|
        render :partial => "video_player", :locals => {:entity => entity, :options => options}
      end

      result['video'] = Proc.new do |entity, options|
        render :partial => "video_player", :locals => {:entity => entity, :options => options}
      end

      result['audio'] = Proc.new do |entity, options|
        render :partial => "video_player", :locals => {:entity => entity, :options => options}
      end

      result
    end

end
