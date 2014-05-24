class Stdlib::KorWillPaginateRenderer < WillPaginate::ViewHelpers::LinkRenderer
  def to_html
    html = I18n.t('nouns.page')

    # previous/next buttons
    if current_page != 1
      html += " " + @template.link_to(@options[:previous_label], url(@collection.previous_page))
    end

    html += " " + I18n.t('out_of', :all => total_pages, :current => current_page )

    if current_page != total_pages
      html += " " + @template.link_to(@options[:next_label], url(@collection.next_page))
    end

    @options[:container] ? html_container(html) : html
  end
end
