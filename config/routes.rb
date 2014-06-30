HyperAlerts::Application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  root to: "home#index"

  devise_for :users, controllers: { :omniauth_callbacks => "users/omniauth_callbacks" }

  resources :users do
    post :migrate, on: :member
    get :time_zone_difference, on: :member
  end

  resources :subscriptions

  get "help/" => "help#index"
  get "statistics/summary" => "statistics#summary"

  # Preview e-mails in development
  if Rails.env.development?
    mount UserMailerPreview => "user_mailer_preview"
    mount SubscriptionMailerPreview => "subscription_mailer_preview"
  end

  # Non-idempotent GET request to destroy subscriptions upon clicking a link in the e-mail
  get "subscriptions/:id/destroy" => "subscriptions#destroy", as: "destroy_subscription"

  # Non-idempotent GET request to destroy users upon clicking a link in the e-mail
  get "users/:id/destroy" => "users#destroy", as: "destroy_user"

  namespace :services do
    namespace :twitter do
      resource :users do
        get "search" => "users#search"
      end
    end
    namespace :facebook do
      get "realtime", to: "real_time#verify"
      post "realtime", to: "real_time#push"
    end
  end

  resources :notifications do
    post :email, on: :collection
  end

  match "/404", to: "errors#not_found"
  match "/500", to: "errors#internal_server_error"
end
