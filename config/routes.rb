# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :slack do
    post 'events/receive'
  end

  root to: 'application#no_content'
end
