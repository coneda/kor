module ToolsHelper

  def clipboard_actions_for_select
    result = [ 'choose' ]
    
    result += [ 'prepare_merge' ] if authorized?(:create)
    result += [ 'mass_relate' ] if authorized?(:edit)
    result += [ 'mass_destroy' ] if authorized?(:delete)
    result += [ 'add_to_user_group' ]
    result += [ 'add_to_authority_group' ] if current_user.authority_group_admin?
    result += [ 'move_to_collection' ] if authorized?([:create, :delete])
    
    options_for_select result.collect{|e| [ I18n.t('clipboard_actions.' + e), e ]}
  end

  def marked?(entity)
    (clipboard || []).include? entity.id.to_i
  end
  
  def clipboard
    current_user ? current_user.clipboard : []
  end
  
  def clipboard_entities
    Entity.find_all_by_id(clipboard)
  end
  
  def joined_comments_for(entities)
    result = ""
    entities.each do |e|
      unless e.comment.blank?
        result += "\n\n#{e.uuid}:\n"
        result += e.comment
      end
    end
    result.strip
  end
  
end
