Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
  resources :lessons, only: :show, param: :slug
  get "enroll/:code", to: "enrollments#show", as: :enroll
  post "enroll/:code", to: "enrollments#create"

  get "llms.txt" => "llms#show", format: false

  namespace :api do
    get "openapi.json" => "openapi#show", format: false
    match "openapi.json", to: "openapi#preflight", via: :options, format: false
    resources :lessons, only: [ :index, :show ], param: :slug
    match "lessons", to: "lessons#preflight", via: :options
    match "lessons/:slug", to: "lessons#preflight", via: :options

    resources :labs, only: [ :index, :show ], param: :slug
    match "labs", to: "labs#preflight", via: :options
    match "labs/:slug", to: "labs#preflight", via: :options
    # Nested or encoded lab paths are unknown labs, answered as JSON like any other.
    get "labs/*slug", to: "labs#show", format: false

    post "enroll" => "enroll#create"
    match "enroll", to: "enroll#preflight", via: :options

    resources :enrollments, only: [ :create, :show ], param: :code
    match "enrollments", to: "enrollments#preflight", via: :options
    match "enrollments/:code", to: "enrollments#preflight", via: :options

    get "progress/:student_id" => "progress#show"
    put "progress/:student_id" => "progress#update"
    delete "progress/:student_id" => "progress#destroy"
    match "progress/:student_id", to: "progress#preflight", via: :options

    get "instructions/:student_id" => "instructions#show"
    match "instructions/:student_id", to: "instructions#preflight", via: :options
  end
end
