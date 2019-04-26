<kor-ask-choices>

  <div class="kor-content-box" if={ready()}>

    <a
      href="#"
      onclick={all}
      title={t('all')}
    >{t('all')}</a> |
    <a
      href="#"
      onclick={none}
      title={t('none')}
    >{t('none')}</a>

    <hr />

    <virtual each={choice in opts.choices}>
      <kor-input
        label={choice.name || choice.label}
        name={choice.id || choice.value}
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
      tag.set(tag.opts.riotValue || []);
    })

    tag.one('updated', function() {
      tag.set(tag.opts.riotValue || []);
    })

    tag.on('mount', function() {
      tag.update();
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

    tag.all = function(event) {
      event.preventDefault();
      var ids = [];
      for (var i = 0; i < tag.opts.choices.length; i++) {
        var c = tag.opts.choices[i];
        ids.push(c.id || c.value);
      }
      tag.set(ids);
      tag.update();
    }

    tag.none = function(event) {
      event.preventDefault();
      tag.set([]);
      tag.update();
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

    tag.set = function(values) {
      tag.ids = values;
      var choices = tag.refs['choices'] || [];
      for (var i = 0; i < choices.length; i++) {
        var c = choices[i];
        var v = (tag.ids.indexOf(c.name()) != -1);
        c.set(v);
      }
    }
  </script>

</kor-ask-choices>