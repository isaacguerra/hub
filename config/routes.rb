Rails.application.routes.draw do
  resources :regioes
  resources :municipios
  # API Routes
  namespace :api do
    get "painel", to: "paineis#show"
    namespace :mobile do
      post "auth/login", to: "auths#login"
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

    resources :municipios do
      resources :regioes do
        resources :bairros
      end
    end
  end

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

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
