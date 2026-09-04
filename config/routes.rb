Rails.application.routes.draw do
  if Rails.env.development?
    mount ItsSwiss::Engine => "/its-swiss"
  end

  # The tools. Each is a whole application at its own path, and the list of
  # them is the chassis's only knowledge of what it carries.
  Chassis::Engines.all.each do |engine|
    mount engine.constant, at: engine.path, as: engine.name.underscore
  end

  # The door. One account, made by whoever arrives at an empty chassis first,
  # and shut behind them.
  resource :session
  resources :passwords, param: :token
  resource :registration, only: %i[ new create ], path: "sign_up", path_names: { new: "" }

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # The bay: what is mounted, and where.
  root "home#show"
end
