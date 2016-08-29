kor.directive "korFileUpload", [
  "korTranslate", "korData", "$timeout",
  (kt, kd, to) ->
    directive = {
      scope: {
        data: "=korFileUpload"
      }
      link: (scope, element, attrs) ->
        uploader = new plupload.Uploader(
          browse_button: element[0]
          url: '/entities'
          headers: {'accept': 'application/json'}
          file_data_name: "entity[medium_attributes][document]"
        )

        scope.max_file_size = -> 
          if kd.info then kd.info.config.max_file_size else 0
        scope.$watch 'max_file_size()', (new_value) ->
          v = parse_int(new_value)
          setting = if v < 1
            "#{v * 1024}kb"
          else
            "#{v}mb"
          uploader.setOption "filters", {max_file_size: setting}
            

        scope.data = {
          jobs: -> uploader.files
          submit: -> 
            uploader.setOption "multipart_params", {
              "entity[kind_id]": scope.data.params.kind_id
              "entity[collection_id]": scope.data.params.collection_id
              "user_group_name": scope.data.params.user_group_name
              "relation_name": scope.data.params.relation_name
            }
            uploader.start()
          abort: -> 
            uploader.stop()
            uploader.splice(0, uploader.files.length)
          remove: (file, event) ->
            event.preventDefault() if event
            uploader.removeFile(file)
          params: {
            kind_id: 1
          }
        }

        prefill_fields = ->
          scope.data.params.user_group_name = kt.localize(new Date)
          scope.data.params.collection_id = try
            kd.info.session.user.auth.collections['create'][0]
          catch e
            undefined
          

        if kd.info
          prefill_fields()
        else
          scope.$on "kor-session-load-complete", prefill_fields

        uploader.bind "QueueChanged", (up) ->
          scope.$apply_safely()

        uploader.bind "UploadProgress", (up, file) ->
          scope.$apply_safely()

        uploader.bind "FileUploaded", (up, file, response) ->
          doit = -> scope.data.remove(file)
          to(doit, 300)

        uploader.bind "Error", (up, error) ->
          if error.code == -600
            message = kt.translate 'errors.file_too_big', interpolations: {
              file: error.file.name
              size: (error.file.origSize / 1024.0 / 1024.0).toFixed(2)
              max: scope.max_file_size()
            }
            window.alert message
          else
            error.parsed_response = JSON.parse(error.response)
            error.file.error = error
            scope.$apply_safely()

        uploader.init()

        scope.$apply_safely = ->
          unless scope.$root.$$phase == "$apply" || scope.$root.$$phase == "$digest"
            scope.$apply() 

        parse_int = (str) ->
          int = parseInt(str)
          if isNaN(int) then 0 else int
    }
]