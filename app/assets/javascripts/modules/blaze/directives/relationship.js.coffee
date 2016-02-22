kor.directive "korRelationship", ["entities_service", "session_service",
  "relationships_service", "kor_tools", 'korData', 'templates_service'
  (es, ss, rss, kt, kd, ts) ->
    directive = {
      template: -> ts.get('relationship')
      scope: {
        directed_relationship: "=korRelationship"
        entity: "=korEntity"
        master_toggle: "=korMasterToggle"
        existing: "@korExisting"
      }
      replace: true
      link: (scope, element, attrs) ->
        scope.allowed_to = (policy, entity) ->
          entity ||= scope.entity
          ss.allowed_to(policy, entity)
        scope.allowed_to_any = ss.allowed_to_any

        scope.visible = false
        scope.page = 1
        scope.editing = false

        scope.$watch "page", (new_value) ->
          if scope.visible
            load_media()

        scope.$watch "master_toggle", ->
          scope.switch(true, scope.master_toggle)

        scope.switch = (force = false, value = null, event) ->
          event.preventDefault() if event
          r = scope.directed_relationship
          if force
            if value
              if !r.media || r.media.length == 0
                load_media()
              scope.visible = true
            else
              scope.visible = false
          else
            if scope.visible
              scope.visible = false
            else
              if !r.media || r.media.length == 0
                load_media()
              scope.visible = true

        scope.edit = (event) -> 
          event.preventDefault() if event
          scope.editing = true

        scope.destroy = (event) ->
          event.preventDefault()

          if confirm($(event.target).attr('kor-confirm'))
            rss.destroy(scope.directed_relationship.relationship_id).success (data) ->
              kd.set_notice(data.message)
              scope.$emit 'relationship-saved'

        load_media = ->
          es.deep_media_load(scope.directed_relationship.to_id, scope.page).success (data) ->
            scope.media = kt.in_groups_of(data, 3, true)

        scope.close_editor =  -> scope.editing = false

    }
]