<kor-welcome>
  
  <div class="kor-content-box">
    <h1>{config().app.welcome_title}</h1>

    <div class="target"></div>

    <div class="teaser" if={currentUser()}>
      <span>{t('pages.random_entities')}</span>
      <div class="hr"></div>
      <kor-gallery-grid entities={entities()} />
    </div>
  </div>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.config)

    tag.on 'mount', ->
      Zepto(tag.root).find('.target').html tag.config().app.welcome_html

      Zepto.ajax(
        url: '/entities/random'
        data: {include: 'gallery_data'}
        success: (data) ->
          tag.data = data
          tag.update()
      )

    tag.entities = ->
      (tag.data || {}).records || []
  </script>

</kor-welcome>