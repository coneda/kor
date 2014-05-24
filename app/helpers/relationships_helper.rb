module RelationshipsHelper

  def commands_for_relationship(relationship, user, options = {})
    result = ""
    
    if user.allowed_to('relationships_edit')
      result << link_to(kor_command_image('pen'), edit_relationship_path(relationship).to_s)
    end

    if user.allowed_to('relationships_destroy')
      result << link_to(kor_command_image('x'), relationship,
        :method => :delete, 
        :confirm => I18n.t("confirm.delete_relationship")
      )
    end
    
    result.html_safe
  end

end

