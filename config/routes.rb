ActionController::Routing::Routes.draw do |map|
  map.resources :attachments_by_url,
                :only => [:create, :destroy],
                :member => { :state => :get }
end
