class ComponentSearchController < ApplicationController

  def component_search
    respond_to do |format|
      format.html {render :layout => 'small_normal_bare'}
      format.json do
        @results = elastic.search(
          :query => params[:terms],
          :kind_id => params[:kind_id],
          :tags => params[:tags],
          :page => params[:page],
          :per_page => params[:per_page]
        )

        entities = @results.records.map do |entity|
          images = entity.media(current_user).first(4).map{|i| {:id => i.id, :url => i.medium.url(:thumbnail)}}
          {:id => entity.id, :name => entity.display_name, :kind => entity.kind_name, :images => images}
        end
        
        render :json => {:total => @results.total, :entities => entities, :page => @results.page}
      end
    end
  end
  
  def counts
    @tags = Entity.without_media.filtered_tag_counts(params[:term])
    @tags = @tags.map do |tag_count|
      type = I18n.t('nouns.tag', :count => 1).capitalize_first_letter
      value = tag_count.name
      count = tag_count.count
      label = "<b>#{type}</b>: #{h tag_count.name} (#{count})"
      
      {:label => label, :value => "tag|#{tag_count.name}"}
    end
    
    @query = elastic.search(:query => params[:term])
    result = [{:label => "<b>#{I18n.t('nouns.term', :count => 1)}</b> '#{params[:term]}' (#{@query.total})", :value => "term|#{params[:term]}"}]
    
    render :json => result + @tags
  end


  protected

    def elastic
      @elastic ||= Kor::Elastic.new(current_user)
    end
  
end
