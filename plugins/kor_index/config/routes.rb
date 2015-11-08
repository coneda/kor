Rails.application.routes.draw do
  controller 'component_search' do
    get '/component_search', :action => 'component_search'
    get '/component/tag_counts', :action => 'counts'
  end
end

