<kor-gallery-grid>

  <table>
    <tbody>
      <tr each={row in inGroupsOf(4, opts.entities, false)}>
        <td each={entity in row}>
          <virtual if={entity && entity.medium}>
            <kor-entity
              entity={entity}
              publishment={opts.publishment}
              authority-group-id={opts.authorityGroupId}
              user-group-id={opts.userGroupId}
            />
            
            <div class="meta" if={entity.primary_entities}>
              <div class="hr"></div>
              <div class="name">
                <a
                  each={e in secondaries(entity)}
                  href="#/entities/{e.id}"
                >{e.display_name}</a>
              </div>
              <div class="desc">
                <a
                  each={e in primaries(entity)}
                  href="#/entities/{e.id}"
                >{e.display_name}</a>
              </div>
            </div>
          </virtual>

          <virtual if={entity && !entity.medium}>
            <div class="buttons text-right">
              <kor-clipboard-control
                if={!opts.noClipboard}
                entity={entity}
              />
              <kor-remove-from-group
                if={opts.authorityGroupId || opts.userGroupId}
                type={opts.authorityGroupId ? 'authority' : 'user'}
                group-id={opts.authorityGroupId || opts.userGroupId}
                entity={entity}
              />
            </div>

            <div class="meta">
              <div class="name">
                <a href="#/entities/{entity.id}">{entity.display_name}</a>
              </div>
              <div class="desc">{entity.kind.name}</div>
            </div>
          </virtual>
        </td>
      </tr>
    </tbody>
  </table>

  <script type="text/javascript">
    var tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)

    tag.inGroupsOf = wApp.utils.inGroupsOf

    tag.primaries = (entity) => {
      results = [...entity.primary_entities]
      return wApp.utils.uniqRecords(results).sort(compare)
    }

    tag.secondaries = (entity) => {
      const results = []
      for (var i = 0; i < entity.primary_entities.length; i++) {
        const p = entity.primary_entities[i]
        for (var j = 0; j < p.secondary_entities.length; j++) {
          const s = p.secondary_entities[j]
          results.push(s)
        }
      }

      return wApp.utils.uniqRecords(results).sort(compare)
    }

    var compare = (a, b) => {
      if (a.display_name < b.display_name) {
        return -1
      }
      if (a.display_name > b.display_name) {
        return 1
      }
      return 0
    }
  </script>

</kor-gallery-grid>