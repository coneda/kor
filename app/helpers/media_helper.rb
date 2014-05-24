module MediaHelper

  def kor_medium(entity, options = {})
    options.reverse_merge!(
      :link => true,
      :style => :thumbnail,
      :buttons => true,
      :wrap => true,
      :user_special => false
    )

    entity = entity.class == Entity ? entity : entity.entity
    medium = entity.medium

    options[:presenter] ||= if options[:use_special]
      select_presenter(medium.content_type)
    else
      select_presenter('image')
    end

    options[:url] ||= entity

    result = options[:presenter].call(entity, options)

    id = "kor_medium_frame_#{entity.id}"
    button_bar = if options[:buttons]
      content_tag 'span', :class => 'button_bar', :style => 'display: none' do
        in_clipboard = (session[:clipboard] || []).include?(entity.id)

        link_to(kor_command_image('target_hit'), '/', :style => (in_clipboard ? nil : 'display: none')) +
        link_to(kor_command_image('target'), '/', :style => (in_clipboard ? 'display: none' : nil))
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
      if medium.content_type.match('video') && Kor.plugin_installed?("kor_video_player")
        link_to I18n.t('verbs.play'), view_medium_path(medium.id)
      elsif medium.content_type.match('image')
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
      "/media/content_types/#{content_type}.gif"
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

      result['video/x-flv'] = Proc.new do |entity, options|
        url = entity.medium.content_type == 'video/x-flv' ? entity.medium.url(:original) : entity.medium.url(:flash)
        lib = javascript_include_tag 'flowplayer.min'
        container = link_to "", url, :style => "display:block;width:100%;height:400px;margin-top:22px;", :id => 'player'
        player = javascript_tag "flowplayer('player', '/assets/flowplayer.swf', {
            clip: {
              scaling: 'fit',
              onStart: function(clip) {
                new_height = $('player').getWidth() / (clip.metaData.width / clip.metaData.height) + 25;
                $('player').style.height = new_height + 'px';
              }
            }
          });"

        lib + container + player
      end

      result['application/x-shockwave-flash'] = Proc.new do |entity, options|
        o = {
          :style => "display:block;width:100%;height:400px;margin-top:22px;",
          :class_id => "clsid:D27CDB6E-AE6D-11cf-96B8-444553540000",
          :width => "100%",
          :height => "400px",
          :id => 'flowplayer'
        }

        params = {
          :movie => "flowplayer.swf",
          :quality => "high",
          :bgcolor =>  '#ffffff',
          :wmode => 'transparent',
          :flashvars => 'config={"clip": "#{entity.medium.path(:original)}"}'
        }

        content_tag 'object', o do
          params.map do |name, value|
            content_tag('param', nil, :name => name, :value => value)
          end.join +
          content_tag('embed', nil,
            :type => "application/x-shockwave-flash",
            :width => '100%',
            :height => '400px',
            :wmode => 'transparent',
            :src => "/plugin_assets/kor_video_player/flash/flowplayer.swf",
            :flashvars => "config={'clip': {'scaling': 'fit', 'url': '#{entity.medium.url(:original)}'}}"
          )
        end
      end

      result['video'] = Proc.new do |entity, options|
        if File.exists? entity.medium.path(:flash)
          result['video/x-flv'].call(entity, options)
        else
          result['image'].call(entity, options)
        end
      end

      result
    end

end
