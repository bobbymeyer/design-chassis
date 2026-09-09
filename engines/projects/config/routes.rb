Projects::Engine.routes.draw do
  # Mounted at /projects, so the resource takes the mount's own path rather
  # than repeating itself: /projects, /projects/new, /projects/2026summer.
  # The tag is the address — it is what a person wrote, and what every tool
  # this gathers from already matches on — so `new` and `api` are names a
  # project may not take. The model refuses them; this is why.
  resources :projects, path: ""

  # The API is versioned from the first commit: other tools depend on this
  # contract, and the way to change it is to add v2, not to edit v1.
  #
  # Read-only. A project is made in the editor; this is for the tools that
  # want to know what is filed where.
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      # The API describes itself, and the description is not behind the token.
      get "openapi", to: "openapi#show", as: :openapi

      resources :projects, only: %i[ index show ] do
        get :items, on: :member
      end
    end
  end

  # The same page as the index above, which is what a tool's root is. Both
  # /projects and /projects/ reach it; the helper writes the second, because
  # a route at an engine's root is the mount path and a slash. Nothing is
  # gained by fighting that, and a link written by hand can say either.
  root "projects#index"
end
