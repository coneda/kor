<kor-upload>

  <div class="kor-layout-left kor-layout-small">
    <div class="kor-content-box">
      <h1>{tcap('verbs.upload')}</h1>

      <form onsubmit={submit}>
        <kor-collection-selector
          policy="create"
          ref="cs"
        />

        <kor-user-group-selector
          type="personal"
          riot-value={l(new Date())}
          ref="user-group-name"
        />

        <virtual if={selection}>
          {tcap('labels.relate_to_via', {interpolations: {to: selection.display_name}})}

          <kor-relation-selector
            if={selection}
            source-kind-id={wApp.info.data.medium_kind_id}
            target-kind-id={selection.kind_id}
            ref="relation-selector"
          />
        </virtual>

        <a class="trigger">
          » {tcap('objects.add', {interpolations: {o: 'nouns.file.other'}})}
        </a>
      </form>
    </div>
  </div>

  <div class="kor-layout-right kor-layout-large">
    <div class="kor-content-box">

      <ul>
        <li each={job in files()}>
          <div class="pull-right">
            <a ref="#" onclick={remove}>x</a>
          </div>
          <strong>{job.name}</strong>
          <div>
            {hs(job.size)}
            <span show={job.percent > 0}>
              <span show={job.percent < 100}>
                {job.percent}
              </span>
              <span show={job.percent == 100 && !job.error}>
                ... {t('done')}
              </span>
            </span>
            <div class="kor-error" if={job.error}>
              <strong>{job.error.parsed_response.message}:
                <div each={errors, field in job.error.parsed_response.errors}>
                  <span>{errors.join(', ')}</span>
                </div>
              </strong>
            </div>
          </div>
        </li>
      </ul>

      <form class="inline" onsubmit={submit}>
        <div class="text-right">
          <kor-input
            type="submit"
            value={tcap('verbs.upload')}
          />
          <kor-input
            type="submit"
            value={tcap('empty_list')}
            onclick={abort}
          />
        </div>
      </form>

    </div>
  </div>

  <div class="clearfix"></div>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.auth);

    var uploader = null;

    tag.on('mount', function() {
      init();
    })

    tag.files = function() {
      if (uploader)
        return uploader.files;
      else
        return [];
    }

    tag.remove = function(event) {
      event.preventDefault();
      uploader.removeFile(event.item.job);
    }

    tag.abort = function(event) {
      event.preventDefault();
      uploader.stop();
      uploader.splice(0, uploader.files.length);
    }

    tag.submit = function(event) {
      event.preventDefault();
      var params = {
        "entity[kind_id]": wApp.info.data.medium_kind_id,
        "entity[collection_id]": tag.refs['cs'].value(),
        "user_group_name": tag.refs['user-group-name'].value(),
        "target_entity_id": wApp.clipboard.selection()
      };
      var rs = tag.refs['relation-selector'];
      if (rs) {
        params['relation_name'] = rs.value();
      }
      uploader.setOption('multipart_params', params);
      uploader.start();
    }

    tag.hasSelection = function() {
      return !!wApp.clipboard.selection();
    }

    var relationSelectorValue = function() {
      return tag.refs['relation-selector'] ?
        tag.refs['relation-selector'].value() :
        nil
    }

    var fetchSelected = function() {
      var id = wApp.clipboard.selection();
      Zepto.ajax({
        url: '/entities/' + id,
        success: function(data) {
          tag.selection = data;
          tag.update();
          tag.refs['relation-selector'].trigger('endpoints-changed');
        },
        error: function(xhr, reason) {
          if (xhr.status == 404) {
            wApp.clipboard.unselect();
            tag.update();
          } else
            console.log(xhr, reason);
        }
      });
    }

    var init = function() {
      if (tag.hasSelection())
        fetchSelected();

      uploader = new plupload.Uploader({
        browse_button: Zepto('.trigger')[0],
        url: '/entities',
        headers: {'accept': 'application/json'},
        file_data_name: "entity[medium_attributes][document]"
      });

      uploader.bind('QueueChanged', function(up) {
        tag.update()
      });

      uploader.bind('UploadProgress', function(up, file) {
        tag.update()
      });

      uploader.bind('FileUploaded', function(up, file, response) {
        var doit = function() {uploader.removeFile(file)};
        setTimeout(doit, 300);
      });

      uploader.bind('Error', function(up, error) {
        if (error.code == -600) {
          var message = tag.t('errors.file_too_big', {
            interpolations: {
              file: error.file.name,
              size: (error.file.origSize / 1024.0 / 1024.0).toFixed(2),
              max: scope.max_file_size()
            }
          });
          window.alert(message);
        } else {
          console.log(error);
          error.parsed_response = JSON.parse(error.response);
          error.file.error = error;
          tag.update();
        }
      });

      uploader.init();
    }

    // tag.uploader.setOption "multipart_params", {
      //   "entity[kind_id]": scope.data.params.kind_id
      //   "entity[collection_id]": scope.data.params.collection_id
      //   "user_group_name": scope.data.params.user_group_name
      //   "relation_name": scope.data.params.relation_name
      // }
      
  </script>

</kor-upload>