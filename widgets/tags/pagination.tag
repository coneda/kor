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

<script type="text/javascript">
  var tag = this;
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);
  tag.mixin(wApp.mixins.config);

  // Get the current page
  tag.currentPage = function() {
    return parseInt(tag.opts.page || 1);
  };

  // Navigate to the first page
  tag.toFirst = function(event) {
    if (event) event.preventDefault();
    tag.to(1);
  };

  // Navigate to the next page
  tag.toNext = function(event) {
    if (event) event.preventDefault();
    tag.to(tag.currentPage() + 1);
  };

  // Navigate to the previous page
  tag.toPrevious = function(event) {
    if (event) event.preventDefault();
    tag.to(tag.currentPage() - 1);
  };

  // Navigate to the last page
  tag.toLast = function(event) {
    if (event) event.preventDefault();
    tag.to(tag.totalPages());
  };

  // Check if the current page is the first page
  tag.isFirst = function() {
    return tag.currentPage() === 1;
  };

  // Check if the current page is the last page
  tag.isLast = function() {
    return tag.currentPage() === tag.totalPages();
  };

  // Navigate to a specific page
  tag.to = function(newPage) {
    if (newPage !== tag.currentPage() && newPage >= 1 && newPage <= tag.totalPages()) {
      if (Zepto.isFunction(tag.opts.onPaginate)) {
        tag.opts.onPaginate(newPage, tag.opts.perPage);
      } else {
        wApp.routing.query({ page: newPage });
      }
    }
  };

  // Change the number of results per page
  tag.changePerPage = function(newPerPage) {
    if (newPerPage !== tag.opts.perPage) {
      if (Zepto.isFunction(tag.opts.onPaginate)) {
        tag.opts.onPaginate(1, newPerPage);
      }
    }
  };

  // Calculate the total number of pages
  tag.totalPages = function() {
    return Math.ceil(tag.opts.total / tag.opts.perPage);
  };

  // Get options for results per page
  tag.perPageOptions = function() {
    var defaults = [5, 10, 20, 50, 100];
    var results = defaults.filter(function(i) {
      return i < tag.config().max_results_per_request;
    });
    results.push(tag.config().max_results_per_request);
    return results;
  };

  // Handle manual page input change
  tag.inputChanged = function(event) {
    tag.to(parseInt(tag.refs.manual.value()));
  };

  // Handle results per page selection change
  tag.selectChanged = function(event) {
    tag.changePerPage(parseInt(tag.refs.select.value()));
  };

  // Check if pagination is active
  tag.isActive = function() {
    return tag.opts.total && tag.opts.total > tag.opts.perPage;
  };
</script>

</kor-pagination>