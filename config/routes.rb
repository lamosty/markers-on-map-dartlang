Mapengine::Application.routes.draw do

  resources :markers

  root "presentation#index"
end
