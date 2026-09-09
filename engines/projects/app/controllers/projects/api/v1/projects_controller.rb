module Projects
  module Api
    module V1
      class ProjectsController < BaseController
        # The reads go through the public interface, so what a Ruby caller
        # gets and what an HTTP caller gets are one implementation.
        def index
          render json: Projects.projects
        end

        def show
          render json: Projects.project(params[:id]) || not_found
        end

        # What is filed here, without the tree above it.
        def items
          render json: Projects.items(params[:id]) || not_found
        end

        private
          def not_found = raise(ActiveRecord::RecordNotFound)
      end
    end
  end
end
