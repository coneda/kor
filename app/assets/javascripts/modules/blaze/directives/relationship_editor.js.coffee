kor.directive "korRelationshipEditor", [
  "relationships_service", "korData",
  (rs, kd) ->
    directive = {
      scope: {
        directed_relationship: "=korRelationshipEditor"
        source: "=korSourceEntity"
        existing: "@korExisting"
        close: "&korClose"
      }
      templateUrl: "/tpl/relationships/form"
      link: (scope, element) ->
        scope.errors = null

        scope.relation_name
        scope.target = {}
        scope.properties = []

        if scope.directed_relationship
          scope.relation_name = scope.directed_relationship.relation_name
          scope.target = scope.directed_relationship.to
          scope.properties = for prop in scope.directed_relationship.relationship.properties
            {value: prop}

        scope.cancel = -> scope.close()

        scope.save = ->
          relationship = {
            from_id: (scope.source || {}).id
            relation_name: scope.relation_name
            to_id: (scope.target || {}).id
            properties: (prop.value for prop in scope.properties)
          }

          promise = if scope.existing
            rs.update(scope.directed_relationship.relationship.id, relationship)
          else
            rs.create(relationship)

          promise.success (data) -> 
            scope.errors = null
            kd.set_notice(data.message)
            # console.log scope
            scope.$emit 'relationship-saved'
            scope.close()
          promise.error (data) -> 
            # console.log data
            scope.errors = data

        scope.add_property = (event) ->
          event.preventDefault()
          scope.properties.push {value: ""}

        scope.remove_property = (property, event) ->
          event.preventDefault() if event
          index = scope.properties.indexOf(property)
          scope.properties.splice(index, 1) unless index == -1
    }
]
