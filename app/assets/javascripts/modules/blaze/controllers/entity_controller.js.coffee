kor.controller('entity_controller', [
  '$scope', '$routeParams', 'entities_service', '$location', 
  'session_service',
  (scope, rp, es, l, ss) ->
    scope.in_clipboard = -> ss.in_clipboard(scope.entity)
    scope.allowed_to = (policy) -> ss.allowed_to(policy, scope.entity)
    scope.allowed_to_any = ss.allowed_to_any

    update = ->
      promise = es.show(rp.id)
      promise.success (data) ->
        scope.entity = data
      promise.error (data) ->
        return_to = document.location.href
        l.path("/denied")
        l.search('return_to': return_to)
    update()

    scope.$on 'relationship-saved', update

    scope.toggle_relationship_editor = (event) ->
      event.preventDefault()
      scope.relationship_editor_visible = !scope.relationship_editor_visible

    scope.visible_entity_fields = ->
      if scope.entity
        scope.entity.fields.filter (field) ->
          field.value && field.show_on_entity
      else
        []

    scope.show_tags = ->
      if scope.entity
        scope.entity.kind.settings.tagging &&
        (
          (scope.entity.tags && scope.entity.tags.length > 0) ||
          scope.allowed_to('tagging', scope.entity.collection_id)
        )

    scope.authority_groups = ->
      if scope.entity
        @authority_groups_with_ancestry ||= for group in scope.entity.groups
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

    scope.close_relationship_editor = ->
      scope.relationship_editor_visible = false

    scope.openMirador = (entity_id, $event) ->
      $event.preventDefault()
      $event.stopPropagation()
      
      root_url = document.location.href.match(/^(https?\:\/\/[^\/]+\/)/)[0]
      url = "#{root_url}/mirador?manifest=#{root_url}mirador/#{entity_id}"
      scope.ow(url)
      true

    scope.ow = (url) -> window.open(url, '', 'height=800,width=1024')

])
