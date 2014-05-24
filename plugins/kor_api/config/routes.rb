Rails.application.routes.draw do
  match '/api/:api_section/:api_action', :to => 'api#invoke'
end
