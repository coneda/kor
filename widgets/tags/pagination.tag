<kor-pagination show={isActive()}>

  <span>{t('nouns.page')}</span>
  <a show={!isFirst()} onclick={toPrevious}><i class="icon pager_left"></i></a>
  <kor-input
    type="number"
    value={currentPage()}
    onchange={inputChanged}
    ref="manual"
  />
  {t('of', {interpolations: {amount: totalPages()}})}
  <a show={!isLast()} onclick={toNext}><i class="icon pager_right"></i></a>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)

    tag.currentPage = -> parseInt(tag.opts.page || 1)
    tag.toFirst = (event) ->
      event.preventDefault() if event
      tag.to(1)
    tag.toNext = (event) ->
      event.preventDefault() if event
      tag.to(tag.currentPage() + 1)
    tag.toPrevious = (event) ->
      event.preventDefault() if event
      tag.to(tag.currentPage() - 1)
    tag.toLast = (event) ->
      event.preventDefault() if event
      tag.to(tag.totalPages())

    tag.isFirst = -> tag.currentPage() == 1
    tag.isLast = -> tag.currentPage() == tag.totalPages()

    tag.to = (new_page) ->
      if new_page != tag.currentPage() && new_page >= 1 && new_page <= tag.totalPages()
        if Zepto.isFunction(tag.opts.pageUpdateHandler)
          tag.opts.pageUpdateHandler(new_page)

    tag.totalPages = ->
      Math.ceil(tag.opts.total / tag.opts.perPage)

    tag.inputChanged = (event) ->
      tag.to parseInt(tag.refs.manual.value())

    tag.isActive = ->
      tag.opts.total && (tag.opts.total > tag.opts.perPage)

  </script>

</kor-pagination>