RedmineApp::Application.routes.draw do
  resources :attachments_by_url, :only => [:create, :destroy] do
    member do
      get :state
    end
  end
end
