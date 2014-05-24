class TagsController < ApplicationController
  
  def index
    @tag_counts = Entity.filtered_tag_counts(params[:term])
    render :json => @tag_counts.map{|tag| {:label => "#{h(tag.name)} (#{tag.count})", :value => h(tag.name)}}
  end
  
end
