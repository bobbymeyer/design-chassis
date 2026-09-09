module Projects
  # Every screen inherits the host's door. The engine never learns what a
  # user is; it only knows that whoever is here got past whatever the host
  # asks.
  class ApplicationController < Projects.base_controller_class.constantize
    layout "projects/application"
  end
end
