module Projects
  module Api
    module V1
      # Every endpoint inherits the host's API door, the way every screen
      # inherits the host's.
      class BaseController < Projects.api_base_controller_class.constantize
        rescue_from ActiveRecord::RecordNotFound do
          render json: { error: "Not found" }, status: :not_found
        end
      end
    end
  end
end
