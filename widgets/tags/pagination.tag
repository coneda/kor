<kor-pagination>

  <virtual if={isActive()}>
    <button onclick={inputChanged}>
      {t('goto', {interpolations: {where: ''}})}
    </button>
    <span>{t('nouns.page')}</span>
    <a
      title={t('previous')}
      show={!isFirst()}
      onclick={toPrevious}
      href="#"
    ><i class="fa fa-arrow-left"></i></a>
    <kor-input
      type="number"
      value={currentPage()}
      onchange={inputChanged}
      name="page"
      ref="manual"
    />
    {t('of', {interpolations: {amount: totalPages()}})}
    <a
      title={t('next')}
      show={!isLast()}
      onclick={toNext}
      href="#"
    ><i class="fa fa-arrow-right"></i></a>
  </virtual>

  <virtual if={opts.perPageControl}>
    <img src="images/vertical_dots.gif" />
    <kor-input
      type="select"
      options={perPageOptions()}
      value={opts.perPage}
      onchange={selectChanged}
      ref="select"
    />
    {t('results_per_page')}
  </virtual>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.config)

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
        if Zepto.isFunction(tag.opts.onPaginate)
          tag.opts.onPaginate(new_page, tag.opts.perPage)
        else
          wApp.routing.query({page: new_page})

    tag.changePerPage = (new_per_page) ->
      if new_per_page != tag.opts.perPage
        if Zepto.isFunction(tag.opts.onPaginate)
          tag.opts.onPaginate(1, new_per_page)

    tag.totalPages = ->
      Math.ceil(tag.opts.total / tag.opts.perPage)

    tag.perPageOptions = ->
      defaults = [5, 10, 20, 50, 100]
      results = (i for i in defaults when i < tag.config().max_results_per_request)
      results.push tag.config().max_results_per_request
      results

    tag.inputChanged = (event) ->
      tag.to parseInt(tag.refs.manual.value())

    tag.selectChanged = (event) ->
      tag.changePerPage parseInt(tag.refs.select.value())

    tag.isActive = ->
      tag.opts.total && (tag.opts.total > tag.opts.perPage)

  </script>

</kor-pagination>