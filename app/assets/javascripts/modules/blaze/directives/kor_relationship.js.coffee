kor.directive "korRelationship", ["entities_service", "session_service",
  "relationships_service", "kor_tools",
  (es, ss, rss, kt) ->
    directive = {
      templateUrl: "/tpl/relationship"
      scope: {
        relationship: "=korRelationship"
        entity: "=korEntity"
        master_toggle: "=korMasterToggle"
      }
      replace: true
      link: (scope, element, attrs) ->
        scope.allowed_to = (policy) -> ss.allowed_to(policy, scope.entity)
        scope.allowed_to_any = ss.allowed_to_any

        scope.visible = false
        scope.relationship.page = 1

        scope.$watch "relationship.page", (new_value) ->
          if scope.visible
            load_media()
            # if angular.isNumber(scope.relationship.page)
            #   if scope.relationship.page > 0
            #     load_media()

        scope.$watch "master_toggle", ->
          # console.log arguments
          scope.relationship.visible = scope.master_toggle

        scope.switch = (force = false, value = null, event) ->
          event.preventDefault() if event
          r = scope.relationship
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
          if scope.relationship.editing
            scope.unedit()
          else
            scope.relationship.editing = true

        scope.unedit = (event) -> 
          event.preventDefault() if event
          rss.show(scope.relationship)
          scope.relationship.editing = false

        scope.update = (event) ->
          event.preventDefault() if event
          rss.update(scope.relationship)

        scope.remove_property = (property, event) ->
          event.preventDefault() if event
          index = scope.relationship.properties.indexOf(property)
          scope.relationship.properties.splice(index, 1) unless index == -1

        load_media = ->
          es.deep_media_load(scope.relationship, scope.relationship.page).success (data) ->
            scope.relationship.media = kt.in_groups_of(data.relationships, 3, true)

    }
]