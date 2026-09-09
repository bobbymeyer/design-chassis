module Projects
  class ProjectsController < ApplicationController
    before_action :set_project, only: %i[ show edit update destroy ]

    # The tree, and a search that narrows it by name. No filter block beyond
    # that: a project's whole purpose is to be the filter.
    def index
      @projects = Project.name_matching(params[:q]).order(:name)
      @projects = Project.in_tree_order if params[:q].blank?
      @total = Project.count
    end

    def show
      @subprojects = @project.children
      @readings = @project.readings
    end

    def new
      @project = Project.new(parent: Project.friendly(params[:parent]))
    end

    def edit
    end

    def create
      @project = Project.new(project_params)

      if @project.save
        redirect_to @project, notice: "#{@project.name} started."
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @project.update(project_params)
        redirect_to @project, notice: "#{@project.name} saved."
      else
        render :edit, status: :unprocessable_content
      end
    end

    # A project holds nothing of its own, so taking one away takes nothing
    # with it: what it gathered is still in the tool that holds it, tagged
    # exactly as before. A project with subprojects will not go, because
    # they would lose the tags that placed them.
    def destroy
      if @project.destroy
        redirect_to projects_path, notice: "#{@project.name} taken away. Nothing it gathered has moved."
      else
        redirect_to @project, alert: @project.errors.full_messages.to_sentence, status: :see_other
      end
    end

    private
      def set_project
        @project = Project.friendly(params[:id]) or raise ActiveRecord::RecordNotFound
      end

      def project_params
        params.expect(project: [ :name, :tag, :note, :parent_id ])
      end
  end
end
