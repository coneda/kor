<kor-welcome>
  
  <div class="kor-content-box">
    <h1>{config().welcome_title}</h1>

    <div class="target"></div>

    <div class="teaser" if={currentUser() && !isGuest()}>
      <span>{tcap('pages.random_entities')}</span>
      <div class="hr"></div>
      <kor-gallery-grid entities={entities()} />
    </div>
  </div>

  <script type="text/javascript">
    let tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.config)
    tag.mixin(wApp.mixins.page)

    tag.on('mount', () => {
      Zepto(tag.root).find('.target').html(tag.config().welcome_html)

      Zepto.ajax({
        url: '/entities',
        data: {
          include: 'gallery_data',
          sort: 'random',
          per_page: 4,
          kind_id: (
            tag.config()['welcome_page_only_media'] ?
            wApp.info.data.medium_kind_id :
            ''
          )
        },
        success: (data) => {
          tag.data = data
          tag.update()
        }
      })
    })

    tag.entities = () => {
      return (tag.data || {}).records || []
    }
  </script>

</kor-welcome>