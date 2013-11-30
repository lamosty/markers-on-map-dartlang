Mapengine::Application.routes.draw do

  resources :markers

  root "markers#index"
end
