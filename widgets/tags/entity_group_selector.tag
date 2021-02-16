<kor-entity-group-selector>

  <kor-input
    if={groups}
    label={tcap('activerecord.models.' + opts.type + '_group')}
    name={opts.id}
    type="select"
    ref="input"
    options={groups}
    riot-value={opts.riotValue}
    errors={opts.errors}
  />  

  <script type="text/javascript">
    var tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)

    tag.on('mount', function() {
      Zepto.ajax({
        url: '/' + tag.opts.type + '_groups',
        data: {
          include: 'directory',
          per_page: 500
        },
        success: function(data) {
          tag.groups = data.records;
          for (var i = 0; i < data.records.length; i++) {
            var r = data.records[i];
            if (r.directory) {
              var names = [];
              var containers = [r.directory].concat(r.directory.ancestors);
              for (var j = 0; j < containers.length; j++) {
                var a = containers[j];
                names.push(a.name);
              }
              names.push(r.name);
              r.name = names.join(' » ');
            }
          }

          // sort the values (easier to to in JS because here, we can directly
          // sort according to directory names first
          tag.groups = tag.groups.sort((x, y) => {
            return x.name.localeCompare(y.name)
          })

          if (tag.opts.riotValue) {
            tag.groups.unshift({
              name: tag.tcap('objects.create_group', {interpolations: {o: tag.opts.riotValue}}),
              value: tag.opts.riotValue
            })
          }

          console.log(tag.groups[0])

          tag.update();
        }
      })
    })

    tag.name = function() {
      return tag.opts.name;
    }

    tag.value = function() {
      return tag.refs['input'].value();
    }
  </script>

</kor-entity-group-selector>