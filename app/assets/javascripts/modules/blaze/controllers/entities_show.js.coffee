kor.controller('korEntitiesShowCtrl', [
  '$scope', 'korData', 'relationships_service',
  (scope, korData, rss) ->

    scope.$on 'kor-initial-load-complete', ->
      scope.entity = korData.entity
      
    scope.$on 'kor-deep-media-load-complete', (event, relationship, data, page) ->
      relationship.media = []

      row = []
      for r in data.relationships
        if row.length == 3
          relationship.media.push row
          row = []

        row.push r.entity

      if row.length > 0
        row.push {} while row.length < 3
        relationship.media.push row

      relationship.media_page = page
      
    scope.$on 'kor-relation-load-complete', (event, relation, data, page) ->
      relation.relationships = data.relationships
      relation.page = page

    scope.page_deep_media = (relationship, page = 1, event) ->
      scope.current_deep_relationship = relationship
      korData.deep_media_load(relationship, page)

      event.preventDefault() if event

    scope.show_link = (link) ->
      if link.header
        result = false

        for k, v of link.links
          result = true

        result
      else
        !!link[1]

      
    scope.page_relation = (relation, page = 1, event) ->
      korData.relation_load(relation, page)
      event.preventDefault() if event
      
    scope.page_media_relation = (relation, page = 1, event) ->
      korData.media_relation_load(relation, page)
      event.preventDefault() if event
      
    scope.switch_relation = (relation, event) ->
      for r in relation.relationships
        scope.switch_relationship_panel(r, true, !relation.visible)
      
      relation.visible = !relation.visible
      event.preventDefault() if event

    scope.total_relation_pages = (relation) -> relation.total_pages ||= Math.ceil(relation.amount / 10)
      
    scope.switch_relationship_panel = (relationship, force = false, value = null, event) ->
      if force
        if value
          relationship.total_media_pages = Math.floor(relationship.total_media / 12) + 1
          if !relationship.media || relationship.media.length == 0
            scope.page_deep_media(relationship)
          relationship.visible = true
        else
          relationship.visible = false
      else
        if relationship.visible
          relationship.visible = false
        else
          relationship.total_media_pages = Math.floor(relationship.total_media / 12) + 1
          if !relationship.media || relationship.media.length == 0
            scope.page_deep_media(relationship) 
          relationship.visible = true

      event.preventDefault() if event
    
    scope.in_clipboard = ->
      if korData.info && korData.entity
        korData.info.session.clipboard ||= []
        korData.info.session.clipboard.indexOf(korData.entity.id) != -1
      else
        false
        
    scope.allowed_to = (policy, object = null) ->
      if korData.info && korData.entity
        object ||= korData.entity.collection_id
        korData.info.session.user.auth.collections[policy] ||= []
        korData.info.session.user.auth.collections[policy].indexOf(object) != -1
      else
        false
        
    scope.allowed_to_any = (policy) ->
      if korData.info
        korData.info.session.user.auth.collections[policy].length != 0
      else
        false

    scope.visible_entity_fields = ->
      if korData.entity
        korData.entity.fields.filter (field) ->
          field.value && field.settings.show_on_entity == "1"
      else
        []

    scope.authority_groups = ->
      if scope.entity
        @authority_groups_with_ancestry ||= for group in scope.entity.authority_groups
          result = {
            name: group.name
            ancestry: []
            id: group.id
          }
          category = group.authority_group_category

          while category
            result.ancestry.unshift category.name
            category = category.parent

          result

    scope.submit = (event) ->
      link = $(event.currentTarget)
      form = link.parents('form')
      confirm = link.data('confirm')

      if confirm
        if window.confirm(confirm)
          form.submit()
      else
        form.submit()
        
      event.preventDefault()
      event.stopPropagation()

    korData.initial_load()


    # Edit relationship

    scope.edit_relationship = (relationship, event) -> 
      event.preventDefault() if event
      if relationship.editing
        scope.unedit_relationship(relationship)
      else
        relationship.editing = true

    scope.unedit_relationship = (relationship, event) -> 
      event.preventDefault() if event
      rss.show(relationship)
      relationship.editing = false

    scope.update_relationship = (relationship, event) ->
      event.preventDefault() if event
      rss.update(relationship)

    scope.remove_relationship_property = (relationship, property, event) ->
      event.preventDefault() if event
      index = relationship.properties.indexOf(property)
      relationship.properties.splice(index, 1) unless index == -1



])
