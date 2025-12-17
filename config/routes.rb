Rails.application.routes.draw do
  # API Routes
  namespace :api do
    namespace :mobile do
      post "auth/login", to: "auths#login"
    end
    namespace :chatbot do
      post "webhook", to: "webhook#receive"
    end
  end

  # Magic Link
  get "m/:codigo", to: "mobile/sessions#create", as: :magic_link

  # Mobile root (usado por redirects mobile)
  get "mobile", to: "mobile/home#index", as: :mobile_root

  
  resources :regioes
  resources :municipios
  # Authentication Routes
  get "login", to: "sessions#new"
  post "sessions", to: "sessions#create"
  get "sessions/verify", to: "sessions#verify_view"
  post "sessions/verify", to: "sessions#verify"
  delete "logout", to: "sessions#destroy"

    # Public Invite Routes
  get "convite/aceitar/:id", to: "convites_publicos#show", as: :aceitar_convite
  post "convite/aceitar/:id", to: "convites_publicos#accept"
  get "convite/sucesso", to: "convites_publicos#success", as: :sucesso_convite

    # Public Comunicado Routes
  get "comunicado/:comunicado_id/ler/:apoiador_id", to: "comunicados_publicos#ler", as: :ler_comunicado

    # Public Evento Routes
  get "evento/:evento_id/participar/:apoiador_id", to: "eventos_publicos#participar", as: :participar_evento

  resources :funcoes
  resources :eventos
  resources :visitas
  resources :comunicados
  resources :convites
  resources :apoiadores

  resources :municipios do
    resources :regioes do
      resources :bairros
    end
  end

    # Gamification Admin Routes
  namespace :gamification do
    resources :challenges
    resources :configurations, only: [ :index ] do
      member do
        patch :update_weight
        patch :update_level
      end
    end
  end

    root "home#index"


  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
