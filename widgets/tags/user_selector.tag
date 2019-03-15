<kor-user-selector>
  <kor-input
    label={label()}
    name={opts.name}
    placeholder={t('prompts.autocomplete')}
    ref="input"
  />

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.on('mount', function() {
      tag.user_id = tag.opts.riotValue;
      fetch();

      input().on('keydown', function(event) {
        var newValue = tag.refs.input.value();
        if (newValue != tag.old_field_value) {
          tag.old_field_value = newValue;
          tag.user_id = null;
          tag.update();
        }
      });

      // if this is added, then clicking result items doesn't work anymore,
      // waiting for upstream fix:
      // https://github.com/varvet/tiny-autocomplete/issues/25
      // input().on('blur', function(event) {
        // Zepto(tag.root).find('.autocomplete-list').remove();
      // })
    })

    tag.on('update', function() {
      // we have to do this here because recalculating the select options
      // creates the options only during an update
      var newUserId = tag.opts.riotValue;
      if (tag.user_id != newUserId) {
        tag.user_id = newUserId;
        fetch();
      }
    })

    tag.on('updated', function() {
      input().tinyAutocomplete({
        method: 'get',
        url: 'http://localhost:3000/users',
        queryProperty: 'terms',
        grouped: false,
        itemTemplate: '<li class="autocomplete-item">{{full_name}}</li>',
        onSelect: function(el, val) {
          tag.user_id = val.id;
          tag.refs.input.set(val.display_name);
          tag.old_field_value = val.display_name;
          Zepto(tag.root).trigger('change');
        }
      });

      tag.autocomplete = input().tinyAutocomplete();
    })

    tag.label = function() {
      if (tag.user_id) {
        return tag.opts.label + ' ✔';
      } else {
        return tag.opts.label;
      }
    }

    tag.name = function() {
      return tag.refs.input.name();
    }

    tag.value = function() {
      return tag.user_id;
    }

    tag.set = function(user_id) {
      tag.user_id = user_id;
      fetch();
    }

    var input = function() {
      return Zepto(tag.refs.input.root).find('input');
    }

    var fetch = function() {
      Zepto.ajax({
        url: '/users/' + tag.user_id,
        success: function(data) {
          tag.refs.input.set(data.display_name);
          tag.old_field_value = data.display_name;
          tag.update();
        },
        error: function(xhr) {
          tag.refs.input.set('');
          xhr.noMessaging = true;
        }
      })
    }
  </script>
</kor-user-selector>