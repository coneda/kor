Rails.application.routes.draw do
  controller 'component_search' do
    match '/component_search', :action => 'component_search'
    match '/component/tag_counts', :action => 'counts'
  end
end

