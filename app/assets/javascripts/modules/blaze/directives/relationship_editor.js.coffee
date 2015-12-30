kor.directive "korRelationshipEditor", [
  ->
    directive = {
      scope: {
        source: "=korSourceEntity"
        relationship: "=korRelationshipEditor"
      }
      templateUrl: "/tpl/relationships/form"
      link: (scope, element) ->
        console.log scope.source
        # element.hide()
    }
]

kor.directive "korRelationSelector", [
  ->
    directive = {
      scope: {
        source: "korSource"
        target: "korTarget"
        relation_name: "=korRelationName"
      }
      templateUrl: "/tpl/relations/selector"
      link: (scope, element) ->
        console.log scope.source
    }
]