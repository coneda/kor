# TODO: should we actually do this?

wApp.resource = {

}

wApp.mixins.resource = {
  resourceName: -> 'object'
  resourcePluralName: -> this->resourceName + 's'
  index: ->
  show: (id) ->
    Zepto.ajax(
      url: "/#{this->resourcePluralName}/#{id}"
      success: (data) ->
        this.data = data
        this.update()
    )
  create: (params) ->
  update: (id, params) ->
  destroy: (id) ->
  save: (id, params) ->
    if id
      this->update(id, params)
    else
      this->create()
}