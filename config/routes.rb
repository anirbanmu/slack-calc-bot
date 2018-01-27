Rails.application.routes.draw do
  namespace :slack do
    post 'events/new'
  end

  root :to => "application#no_content"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
