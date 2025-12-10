Rails.application.routes.draw do
  # API Routes
  namespace :api do
    get "painel", to: "paineis#show"
    namespace :mobile do
      post "auth/login", to: "auths#login"
    end
    namespace :chatbot do
      post "webhook", to: "webhook#receive"
    end
  end

  # Magic Link
  get "m/:codigo", to: "mobile/sessions#create", as: :magic_link

  # Mobile Namespace
  namespace :mobile do
    root to: "dashboard#index"
    get "dashboard", to: "dashboard#index"
    delete "logout", to: "sessions#destroy"

    resources :apoiadores
    resources :convites
    resources :comunicados
    resources :eventos
    resources :visitas
    resource :perfil, only: [ :show ], controller: "perfil"
    get "estatisticas", to: "estatisticas#index"

    namespace :gamification do
      resources :challenges
      resource :strategy, only: [ :edit, :update ], controller: "strategies"
    end

    get "gamification/perfil/:id", to: "gamification#profile", as: :gamification_profile

    resources :gamification, only: [ :index, :show ], controller: "gamification" do
      member do
        post :participate
      end
    end
    # Redirect legacy/incorrect links from notifications
    get "gamification/challenges/:id", to: redirect("/mobile/gamification/%{id}")

    resources :municipios do
      resources :regioes do
        resources :bairros
      end
    end
  end

  # Web Namespace
  scope module: :web do
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
    resources :apoiadores, except: [ :new, :create ]

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
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
