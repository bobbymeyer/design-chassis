require "test_helper"

module Projects
  class ProjectsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @site = Project.create!(name: "bobbymeyer.com", tag: "bobbymeyerdotcom", note: "The site and everything around it.")
      @summer = Project.create!(name: "Summer 2026", tag: "2026summer", parent: @site)
    end

    test "the index draws the tree, each project indented under the one above it" do
      get projects_path

      assert_response :success
      assert_select "header.page-head h1.page-title", text: "Projects"
      assert_select ".project-tree__row", 2
      assert_select ".project-tree__row[style*='--depth: 0'] .project-tree__name", text: "bobbymeyer.com"
      assert_select ".project-tree__row[style*='--depth: 1'] .project-tree__name", text: "Summer 2026"
      assert_select ".project-tree .tag", text: "#bobbymeyerdotcom"
    end

    test "the index narrows by name as you type" do
      get projects_path(q: "summer")

      assert_select ".filters form[data-controller='its-swiss-live-search'][data-turbo-frame=projects]"
      assert_select "turbo-frame#projects .project-tree__row", 1
      assert_select ".project-tree__name", text: "Summer 2026"

      get projects_path(q: "zzz")
      assert_select ".empty", text: "No projects match."
    end

    test "an empty tool says what a project is for rather than showing an empty list" do
      @summer.destroy!
      @site.reload.destroy!

      get projects_path

      assert_select ".empty", /No projects yet/
    end

    # --- One project ------------------------------------------------------

    test "a project is addressed by its tag" do
      get project_path(@site)

      assert_response :success
      assert_equal "/projects/bobbymeyerdotcom", path
      assert_select "h1.page-title", text: "bobbymeyer.com"
      assert_select ".page-head", /The site and everything around it/
    end

    test "a project draws what each tool answered, one section per tool" do
      source(:palettes, name: "Palettes", mark: "🐼") { |_tag| [ item("Brand Core", %w[ bobbymeyerdotcom ], swatches: %w[ #E30613 #111111 ]) ] }
      source(:patterns, name: "Patterns", mark: "🦓") { |_tag| [ item("Awning", %w[ bobbymeyerdotcom ], image: "/stripeclub/patterns/1/tile.svg") ] }

      get project_path(@site)

      assert_select "#source-palettes h2", /Palettes/
      assert_select "#source-palettes .item-card .card__name", text: "Brand Core"
      assert_select "#source-palettes .item__swatch", 2
      assert_select "#source-patterns .item-card img[src='/stripeclub/patterns/1/tile.svg']"
    end

    # The whole point: the link leaves for the tool that holds the thing.
    test "an item links into the tool that holds it, not into this one" do
      source { |_tag| [ item("Brand Core", %w[ bobbymeyerdotcom ], path: "/pandatone/palettes/3") ] }

      get project_path(@site)

      assert_select ".item-card a[href='/pandatone/palettes/3']"
    end

    test "a subproject is on its parent's page with what it holds counted" do
      source { |_tag| [ item("Poster", %w[ bobbymeyerdotcom 2026summer ]) ] }

      get project_path(@site)

      assert_select ".subproject-card .card__name", text: "Summer 2026"
      assert_select ".subproject-card .card__meta", text: "#2026summer · 1 thing"
      assert_select ".item-card", 0, "what a subproject claims is not repeated at the top"

      get project_path(@summer)
      assert_select ".item-card .card__name", text: "Poster"
    end

    test "a subproject says what has to be carried to be filed in it" do
      get project_path(@summer)

      assert_select ".project-line a", text: "bobbymeyer.com"
      assert_select ".project-line .hint", /carries all of #bobbymeyerdotcom and #2026summer/
    end

    test "a tool that did not answer says so rather than being quietly short" do
      source(:palettes, name: "Palettes") { |_tag| raise IOError, "nobody home" }

      get project_path(@site)

      assert_select "#source-palettes .empty", /Nothing came back from Palettes/
      assert_select "#source-palettes .hint", /nobody home/
    end

    test "no sources registered is a project that says so" do
      get project_path(@site)

      assert_select ".empty", /Nothing is registered to gather from/
    end

    test "a tag nobody has is not found rather than an error" do
      get "/projects/nothing-filed-here"

      assert_response :not_found
    end

    # --- Making and unmaking ---------------------------------------------

    test "a project is started with a name and a tag" do
      post projects_path, params: { project: { name: "Archive", tag: "  ARCHIVE " } }

      assert_redirected_to "/projects/archive"
      assert_equal "archive", Project.find_by(name: "Archive").tag
    end

    test "a subproject is started from its parent's page, with the parent already filled in" do
      get new_project_path(parent: "bobbymeyerdotcom")

      assert_select "select[name='project[parent_id]'] option[selected][value=?]", @site.id.to_s
    end

    test "a tag that is two words is refused and says why" do
      post projects_path, params: { project: { name: "Bad", tag: "two words" } }

      assert_response :unprocessable_content
      assert_select ".errors", /one word/
    end

    test "a tag another project already has is refused" do
      post projects_path, params: { project: { name: "Twin", tag: "bobbymeyerdotcom" } }

      assert_response :unprocessable_content
      assert_select ".errors", /already been taken/
    end

    # /projects/new is this tool's own address, so it cannot also be a project.
    test "a tag that is one of this tool's own addresses is refused" do
      post projects_path, params: { project: { name: "New", tag: "new" } }

      assert_response :unprocessable_content
      assert_select ".errors", /address this tool already uses/
    end

    test "a project can be renamed and re-tagged" do
      patch project_path(@summer), params: { project: { name: "Summer", tag: "summer2026" } }

      assert_redirected_to "/projects/summer2026"
      assert_equal "summer2026", @summer.reload.tag
    end

    test "a project cannot be made its own parent" do
      patch project_path(@site), params: { project: { name: "bobbymeyer.com", tag: "bobbymeyerdotcom", parent_id: @site.id } }

      assert_response :unprocessable_content
      assert_select ".errors", /cannot be the project itself/
    end

    # Nothing a project gathered is a project's to take away.
    test "taking a project away moves nothing it gathered" do
      source { |_tag| [ item("Poster", %w[ 2026summer bobbymeyerdotcom ]) ] }

      delete project_path(@summer)

      assert_redirected_to projects_path
      assert_not Project.exists?(@summer.id)
      follow_redirect!
      assert_select "[role=status]", /Nothing it gathered has moved/
    end

    test "a project with subprojects will not go on its own" do
      delete project_path(@site)

      assert_redirected_to project_path(@site)
      assert Project.exists?(@site.id)
    end

    # --- The door ---------------------------------------------------------

    test "every screen is behind the host's door" do
      sign_out

      get projects_path
      assert_response :unauthorized
    end
  end
end
