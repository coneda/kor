module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the new entries page/ then '/blaze#/entities/gallery'
    when /the new entities page/ then '/entities/recent'
    when /the isolated entities page/ then '/blaze#/entities/isolated'
    when /the config page/ then '/config/general'
    when /the home\s?page/ then '/'
    when /the expert search/ then '/entities'
    when /the global groups page/ then '/authority_group_categories'
    when /^the gallery( page)?$/ then web_path(:anchor => "/entities/gallery")
    when /^page "(\d+)" of the gallery$/
      page = $1
      web_path(:anchor => "/entities/gallery?page=#{page}")
    # when /the new relationship page for "(.*)"/
    #   new_relationship_path(:relationship => {:from_id => Entity.find_by_name($1).id })
    when /the new publishment page/ then new_publishment_path
    when /the publishments page/ then publishments_path
    # when /the new relation page/ then new_relation_path
    when /the new entity page/ then new_entity_path
    when /the authority groups page/ then authority_group_categories_path
    when /the authority group categories page/ then authority_group_categories_path
    when /the user group page for "([^\"]*)"/
      user_group_path(UserGroup.find_by_name($1))
    when /the user groups page/ then user_groups_path
    when /the shared user groups page/ then shared_user_groups_path
    when /the authority group page for "([^\"]*)"/
      authority_group_path(AuthorityGroup.find_by_name($1))
    when /the download authority group page for "([^\"]*)"/
      download_images_authority_group_path(AuthorityGroup.find_by_name($1))
    when /the authority group category page for "([^\"]*)"/
      authority_group_category_path(AuthorityGroupCategory.find_by_name($1))
    when /the entity page for "([^\"]*)"/
      name = $1
      entity = Entity.find_by_name(name)
      web_path(:anchor => entity_path(entity))
    when /the entity page for the (first|last) medium/
      media = Kind.medium_kind.entities
      entity = ($1 == 'first' ? media.first : media.last)
      web_path(:anchor => entity_path(entity))
    when /the (first|last) entity's page/
      media = Kind.medium_kind.entities
      entity = ($1 == 'first' ? media.first : media.last)
      web_path(:anchor => entity_path(entity))
    when /the legacy upload page/ then "/entities/new?kind_id=#{Kind.medium_kind.id}"
    when /the entity page for medium "([0-9]+)"/
      entity = Entity.find($1)
      web_path(:anchor => entity_path(entity))
    when /the kinds page/ then kinds_path
    when /the clipboard/ then '/tools/clipboard'
    when /the new "([^\"]*)-Entity" page/
      new_entity_path(:kind_id => Kind.find_by_name($1).id)
    when /the login page/ then login_path
    when /the new user group page/ then new_user_group_path
    when /the user group "([^\"]*)"/ then user_group_path(UserGroup.find_by_name($1))
    when /the edit page for user group "([^\"]*)"/ then edit_user_group_path(UserGroup.find_by_name($1))
    when /the credentials page/ then credentials_path
    when /the collections page/ then collections_path
    when /the profile page for user "([^\"]+)"/ then edit_self_user_path(User.find_by_name($1))
    when /the users page/ then users_path
    when /the edit page for "([^\"]+)" "([^\"]+)"/
      klass = $1
      name = $2.split('/').first
      object = klass.classify.constantize.find_by_name(name)
      if object.is_a?(Relation)
        "/blaze#/relations/#{object.id}"
      else
        send("edit_#{klass}_path", object)
      end
    when /the relations page/ then '/blaze#/relations'
    when /the simple search page/ then '/component_search'
    when /the edit relationship page for the first relationship/ then edit_relationship_path(Relationship.first)
    when /the new relationship page with target "([^\"]+)"/
      entity = Entity.find_by_name($1)
      new_relationship_path(:relationship => {:from_id => entity.id})
    when /the multi upload page/ then web_path(:anchor => '/entities/multi_upload')
    when /the exception logs page/ then exception_logs_path
    when /welcome page/ then "/"
    when /404/ then "/404.html"
    when /the path "([^\"]+)"/ then $1

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
