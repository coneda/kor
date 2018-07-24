<kor-clipboard>
  
  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <div class="kor-layout-commands">
        <a onclick={reset}><i class="minus"></i></a>
      </div>
      <h1>{tcap('nouns.clipboard')}</h1>

      <div class="hr"></div>

      <span show={data && data.total == 0}>
        {tcap('objects.none_found', {interpolations: {o: 'nouns.entity.one'}})}
      </span>

      <table if={data}>
        <tbody>
          <tr each={entity in data.records}>
            <td>
              <kor-input
                type="checkbox"
                ref="entityIds"
                value={true}
                data-id={entity.id}
              />
            </td>
            <td>
              <a href="#/entities/{entity.id}">
                <span show={!entity.medium}>{entity.display_name}</span>
                <img
                  if={entity.medium}
                  src={entity.medium.url.icon}
                  class="image"
                />
              </a>
            </td>
            <td class="right nobreak">
              <a onclick={remove(entity.id)}><i class="minus"></i></a>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>

  <div class="kor-layout-right kor-layout-small"><div class="kor-content-box"></div></div>

  <div class="clearfix"></div>
  
  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.auth)

    tag.on 'mount', ->
      if tag.currentUser() && !tag.isGuest()
        fetch()
      else
        h() if h = tag.opts.handlers.accessDenied

    tag.selectedIds = ->
      e.opts.dataId for e in tag.refs.entityIds when e.checked()

    tag.reset = (event) -> 
      event.preventDefault()
      h().done(fetch) if h = tag.opts.handlers.reset
      
    tag.remove = (id) ->
      (event) ->
        event.preventDefault()
        h(id).done(fetch) if h = tag.opts.handlers.remove

    fetch = ->
      console.log 'fetching:', tag.opts.entityIds
      Zepto.ajax(
        url: '/clipboard'
        data: {ids: tag.opts.entityIds}
        success: (data) ->
          tag.data = data
          tag.update()
      )

  </script>

</kor-clipboard>