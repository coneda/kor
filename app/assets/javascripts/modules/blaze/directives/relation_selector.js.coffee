kor.directive "korRelationSelector", [
  "relations_service", 'templates_service',
  (rs, ts) ->
    directive = {
      scope: {
        source: "=korSource"
        target: "=korTarget"
        relation_name: "=korRelationSelector"
      }
      template: -> ts.get('relation-selector')
      link: (scope, element, attrs) ->
        update = ->
          from_kind_ids = if scope.source then scope.source.kind_id else null 
          to_kind_ids = if scope.target then scope.target.kind_id else null
          rs.names(from_kind_ids, to_kind_ids).success (data) -> scope.relations = data

        scope.$watch "source", update
        scope.$watch "target", update
    }
]