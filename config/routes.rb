Mapengine::Application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)


  root "presentation#index"

  resources :markers

  # custom API routes

  scope 'api/' do
    get 'markers', to: 'api#markers'
    get 'markers/:id', to: 'api#markers'

    post 'markers', to: 'api#new_markers'
  end

end
