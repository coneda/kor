module NavigationHelpers
  def path_to(page_name)
    case page_name
    when /the home\s?page/ then '/'
    when /the new entries page/ then '#/new-media'
    when /the invalid entities page/ then '#/entities/invalid'
    when /the isolated entities page/ then '#/entities/isolated'
    when /the config page/ then '#/settings'
    when /the search page/ then '#/search'
    when /^the gallery( page)?$/ then '#/new-media'
    when /the new publishment page/ then '#/groups/published/new'
    when /the publishments page/ then '#/groups/published'
    when /the authority groups page/ then '#/groups/categories'
    when /the authority group categories page/ then '#/groups/categories'
    when /the user groups page/ then '#/groups/user'
    when /the shared user groups page/ then '#/groups/shared'
    when /the login page/ then '#/login'
    when /the credentials page/ then '#/credentials'
    when /the collections page/ then '#/collections'
    when /the profile page/ then '#/profile'
    when /the users page/ then '#/users'
    when /the clipboard/ then '#/clipboard'
    when /the new user group page/ then '#/groups/user/new'
    when /the relations page/ then '#/relations'
    when /the upload page/ then '#/upload'
    when 'the mirador page' then '/mirador'
    when /^page "(\d+)" of the gallery$/
      page = $1
      "#/new-media?page=#{page}"
    when /the authority group page for "([^"]*)"/
      id = AuthorityGroup.find_by!(name: $1).id
      "#/groups/admin/#{id}"
    when /the authority group category page for "([^"]*)"/
      id = AuthorityGroupCategory.find_by!(name: $1).id
      "#/groups/categories/#{id}"
    when /the entity page for "([^"]*)"/
      name = $1
      entity = if name.size == 36
        Entity.find_by!(uuid: name)
      else
        Entity.find_by!(name: name)
      end
      "#/entities/#{entity.id}"
    when /the entity page for the (first|last) medium/
      media = Kind.medium_kind.entities
      entity = ($1 == 'first' ? media.first : media.last)
      "#/entities/#{entity.id}"
    when /the entity page for medium "([^"]*)"/
      entity = send($1.to_sym)
      "#/entities/#{entity.id}"
    when /the new "([^"]*)-Entity" page/
      kind_id = Kind.find_by_name($1).id
      "#/entities/new?kind_id=#{kind_id}"
    when /the user group "([^"]*)"/
      id = UserGroup.find_by!(name: $1).id
      "#/groups/user/#{id}"
    when /the edit page for "([^"]+)" "([^"]+)"/
      klass = $1
      name = $2.split('/').first
      object = klass.classify.constantize.find_by_name(name)
      "#/#{klass.pluralize}/#{object.id}/edit"
    when /the path "([^"]+)"/ then $1
    when /url "([^"]+)"/ then $1

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
      rescue Object
        raise(
          "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
        )
      end
    end
  end
end

World(NavigationHelpers)
