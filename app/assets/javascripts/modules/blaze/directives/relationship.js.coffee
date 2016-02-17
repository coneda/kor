kor.directive "korRelationship", ["entities_service", "session_service",
  "relationships_service", "kor_tools",
  (es, ss, rss, kt) ->
    directive = {
      templateUrl: "/tpl/relationship"
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
            # if angular.isNumber(scope.directed_relationship.page)
            #   if scope.directed_relationship.page > 0
            #     load_media()

        scope.$watch "master_toggle", ->
          scope.switch(true, scope.master_toggle)

        scope.switch = (force = false, value = null, event) ->
          event.preventDefault() if event
          r = scope.directed_relationship
          if force
            if value
              # r.total_media_pages = Math.floor(r.total_media / 12) + 1
              if !r.media || r.media.length == 0
                load_media()
              scope.visible = true
            else
              scope.visible = false
          else
            if scope.visible
              scope.visible = false
            else
              # r.total_media_pages = Math.floor(r.total_media / 12) + 1
              window.s = scope
              if !r.media || r.media.length == 0
                load_media()
              scope.visible = true

        scope.edit = (event) -> 
          event.preventDefault() if event
          scope.editing = true

        # scope.unedit = (event) -> 
        #   event.preventDefault() if event
        #   rss.show(scope.directed_relationship)
        #   scope.editing = false

        # scope.update = (event) ->
        #   event.preventDefault() if event
        #   rss.update(scope.directed_relationship.relationship)

        # scope.remove_property = (property, event) ->
        #   event.preventDefault() if event
        #   index = scope.directed_relationship.relationship.properties.indexOf(property)
        #   scope.directed_relationship.relationship.properties.splice(index, 1) unless index == -1

        load_media = ->
          es.deep_media_load(scope.directed_relationship, scope.directed_relationship.page).success (data) ->
            scope.directed_relationship.media = kt.in_groups_of(data.directed_relationships, 3, true)

        scope.close_editor =  -> scope.editing = false

    }
]