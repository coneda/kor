kor.service "session_service", [
  "$http", "korData",
  (http, kd) ->
    service = {
      is_guest: ->
        return false unless kd.info
        if user = kd.info.session.user
          user.name == 'guest'
        else
          false
      allowed_to: (policy, object) ->
        if kd.info && object
          collection_id = if angular.isObject(object)
            object.collection_id
          else
            object

          if kd.info.session.user.auth
            kd.info.session.user.auth.collections[policy] ||= []
            kd.info.session.user.auth.collections[policy].indexOf(collection_id) != -1
          else
            false
        else
          false
      allowed_to_any: (policy) ->
        if kd.info && kd.info.session.user.auth
          kd.info.session.user.auth.collections[policy].length != 0
        else
          false
      in_clipboard: (entity) ->
        if kd.info && entity
          kd.info.session.clipboard ||= []
          kd.info.session.clipboard.indexOf(entity.id) != -1
        else
          false
      is_current: (entity) ->
        if kd.info && entity
          arr = kd.info.session.current_history
          arr[arr.length - 1].id == entity.id
        else
          false
      to_clipboard: (entity) ->
        promise = http(
          method: "get"
          url: "/mark"
          headers: {accept: "application/json"}
          params: {id: entity.id, mark: "mark"}
        )
        promise.success (data) -> 
          if !service.in_clipboard(entity)
            kd.info.session.clipboard.push(entity.id)
      from_clipboard: (entity) ->
        promise = http(
          method: "get"
          url: "/mark"
          headers: {accept: "application/json"}
          params: {id: entity.id, mark: "unmark"}
        )
        promise.success (data) -> 
          if service.in_clipboard(entity)
            index = kd.info.session.clipboard.indexOf(entity.id) != -1
            kd.info.session.clipboard.splice index, 1
      to_current: (entity) ->
        promise = http(
          method: "get"
          url: "/mark_as_current/#{entity.id}"
          headers: {accept: "application/json"}
        )
        promise.success (data) -> kd.info.session.current_history = data

    }
]