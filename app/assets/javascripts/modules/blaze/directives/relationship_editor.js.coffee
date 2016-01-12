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
