module Projects
  module Api
    module V1
      # The API describes itself, and the description is not behind the
      # token: a client that cannot read what the endpoints are cannot ask
      # for one.
      class OpenapiController < ActionController::API
        def show
          render json: Projects.openapi
        end
      end
    end
  end
end
