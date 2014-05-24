class ComponentSearchController < ApplicationController
  unloadable

  def component_search
    @query = kor_graph.search(:sunspot,
      :user => current_user,
      :criteria => {
        :terms => params[:terms],
        :kind_id => params[:kind_id],
        :tags => params[:tags]
      },
      :page => params[:page]
    )
    
    respond_to do |format|
      format.html {render :layout => 'small_normal_bare'}
      format.js do
        entities = @query.results.items.map do |entity|
          images = entity.media(current_user).first(4).map{|i| {:id => i.id, :url => i.medium.url(:thumbnail)}}
          {:id => entity.id, :name => entity.display_name, :kind => entity.kind_name, :images => images}
        end
        
        render :json => {:total => @query.results.total, :entities => entities, :page => @query.page}
      end
    end
  end
  
  def counts
    @tags = Entity.filtered_tag_counts(params[:term])
    @tags = @tags.map do |tag_count|
      type = I18n.t('nouns.tag', :count => 1).capitalize_first_letter
      value = tag_count.name
      count = tag_count.count
      label = "<b>#{type}</b>: #{h tag_count.name} (#{count})"
      
      {:label => label, :value => "tag|#{tag_count.name}"}
    end
    
    @query = kor_graph.search(:sunspot, :criteria => {:terms => params[:term]})
    result = [{:label => "<b>#{I18n.t('nouns.term', :count => 1)}</b> '#{params[:term]}' (#{@query.total})", :value => "term|#{params[:term]}"}]
    
    render :json => result + @tags
  end
  
end
