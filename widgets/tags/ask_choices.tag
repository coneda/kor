<kor-ask-choices>

  <div class="kor-content-box" if={ready()}>
    <virtual each={choice in opts.choices}>
      <kor-input
        label={choice.name || choice.label}
        name={choice.id || choice.value}
        value={isChecked(choice)}
        type="checkbox"
        ref="choices"
      />
      <div class="clearfix"></div>
    </virtual>

    <hr />

    <div class="kor-text-right">
      <button onclick={cancel}>{t('cancel')}</button>
      <button onclick={ok}>{t('ok')}</button>
    </div>
  </div>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.on('before-mount', function() {
      // console.log(tag.opts);
      fromOpts();
    })

    tag.ok = function(event) {
      var results = tag.value();
      tag.opts.modal.trigger('close');
      if (h = tag.opts.notify) {
        h(results);
      }
    }

    tag.cancel = function(event) {
      tag.opts.modal.trigger('close');
    }

    tag.ready = function() {
      return Zepto.isArray(tag.ids);
    }

    tag.value = function() {
      if (Zepto.isArray(tag.refs['choices'])) {
        var results = [];
        for (var i = 0; i < tag.refs['choices'].length; i++) {
          var c = tag.refs['choices'][i];
          if (c.value()) {
            results.push(c.name());
          }
        }
        return results;
      } else {
        return [tag.refs['choices'].value()];
      }
    }

    tag.isChecked = function(choice) {
      // console.log(tag.ids, choice);
      return tag.ids.indexOf(choice.id || choice.value) > -1
    }

    var fromOpts = function() {
      // console.log(tag.opts);
      tag.ids = tag.opts.riotValue || [];
    }
  </script>

</kor-ask-choices>