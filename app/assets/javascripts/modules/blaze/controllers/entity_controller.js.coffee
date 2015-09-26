kor.controller('entity_controller', [
  '$scope', '$routeParams', 'entities_service', '$location', 
  'session_service',
  (scope, rp, es, l, ss) ->
    scope.in_clipboard = -> ss.in_clipboard(scope.entity)
    scope.allowed_to = (policy) -> ss.allowed_to(policy, scope.entity)
    scope.allowed_to_any = ss.allowed_to_any

    promise = es.show(rp.id)
    promise.success (data) -> scope.entity = data
    promise.error (data) -> l.path("/denied")

    scope.visible_entity_fields = ->
      if scope.entity
        scope.entity.fields.filter (field) ->
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

])
