<w-pagination>

  <div class="w-text-right" show={total_pages() > 1}>
    <a
      show={!is_first()}
      onclick={page_to_first}
    ><i class="fa fa-angle-double-left"></i></a>
    <a
      show={!is_first()}
      onclick={page_down}
    ><i class="fa fa-angle-left"></i></a>
    {opts.page}/{total_pages()}
    <a
      show={!is_last()}
      onclick={page_up}
    ><i class="fa fa-angle-right"></i></a>
    <a
      show={!is_last()}
      onclick={page_to_last}
    ><i class="fa fa-angle-double-right"></i></a>
  </div>

  <script type="text/coffee">
    tag = this

    tag.current_page = -> parseInt(wApp.routing.query()['page'] || 1)
    tag.page_to_first = -> tag.page_to(1)
    tag.page_down = -> tag.page_to(tag.current_page() - 1)
    tag.page_up = -> tag.page_to(tag.current_page() + 1)
    tag.page_to_last = -> tag.page_to(tag.total_pages())

    tag.is_first = -> tag.current_page() == 1
    tag.is_last = -> tag.current_page() == tag.total_pages()

    tag.page_to = (new_page) ->
      if new_page != tag.current_page() && new_page >= 1 && new_page <= tag.total_pages()
        wApp.routing.query page: new_page

    tag.total_pages = ->
      Math.ceil(tag.opts.total / tag.opts.per_page)
  </script>

</w-pagination>