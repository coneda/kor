module EntitiesHelper

  def gallery_item(entity)
    render partial: 'layouts/gallery_item', locals: {
      entity: entity,
      primary_entities: entity.primary_entities(current_user)
    }
  end

  def column(name, value, options = {})
    options.reverse_merge!(
      :count => 1,
      :translate => true,
      :scope => 'nouns',
      :newline => false,
      :normal_text_value => false,
      :separate => false,
      :name => true,
      :sanitize => true
    )
  
    unless value.blank?
      if options[:translate]
        name = I18n.t("#{name}", :count => options[:count], :scope => options[:scope]).capitalize_first_letter
      end
      
      tag_classes = options[:normal_text_value] ? 'text' : 'highlighted_subtitle'
      separation = options[:separate] ? '<div class="hr"></div>' : ''
      naming = options[:name] ? "#{name}: " : ""
      if options[:sanitize]
        naming = h(naming)
        value = h(value)
      end
      
      result = separation + (options[:newline] ?
        "#{naming}<div class='#{tag_classes}'>#{value}</div>" :
        "#{naming}<span class='#{tag_classes}'>#{value}</span>"
      )
      
      result.html_safe
    end
  end
  
  def entity_subtitle(entity, content_type = false)
    if entity.is_medium?
      result = ""
      
      if content_type
        label = Medium.human_attribute_name(:original_extension)
        "#{label}: #{content_tag 'span', entity.medium.content_type, :class => 'highlighted_subtitle'}".html_safe
      else
        label = Medium.human_attribute_name(:file_type)
        "#{label}: #{content_tag 'span', entity.medium.original_extension, :class => 'highlighted_subtitle'}".html_safe
      end
    else
      entity.kind_name
    end
  end

  def commands_for_entity(entity, options = {})
    result = "".html_safe
  
    case options[:container]
      when nil
        
      when AuthorityGroup
        if current_user.authority_group_admin?
          result += link_to(
            kor_command_image('minus'), 
            remove_from_authority_group_path(options[:container], :entity_ids => [entity.id])
          )
        end
      when UserGroup
        result += link_to(
          kor_command_image('minus'), 
          remove_from_user_group_path(options[:container], :entity_ids => [entity.id])
        )
      when :self
        if authorized?(:edit, Collection.all, :required => :any)
          result << link_to(kor_command_image('select'), mark_as_current_path(entity))
        end
        
        result << if marked?(entity)
          link_to(kor_command_image('target_hit'), put_in_clipboard_path(:mark => 'unmark', :id => entity.id))
        else
          link_to(kor_command_image('target'), put_in_clipboard_path(:mark => 'mark', :id => entity.id))
        end
        
        if authorized?(:edit, entity.collection)
          result << link_to(kor_command_image('pen'), edit_entity_path(entity))
        end
        
        if authorized?(:delete, entity.collection)
          result << link_to(kor_command_image('x'), entity, :method => :delete, :data => {:confirm => I18n.t('confirm.delete_entity')})
        end
      else
        raise "unknown context #{options[:container].inspect}"
    end
    
    result
  end
  
end
