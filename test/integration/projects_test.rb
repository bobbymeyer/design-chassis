require "test_helper"

# The fourth engine, and the first that reads more than one of its siblings.
#
# What is new here is the direction. Stripeclub asks Pandatone for palettes,
# and Pandatone's dresser is the seam it asks through. Projects asks nothing:
# it depends on no tool, names none, and gathers whatever the chassis
# registered in config/initializers/projects.rb — which is the chassis doing
# the one thing only the chassis may do, and the only place in this
# application where two tools are named in one breath.
class ProjectsTest < ActionDispatch::IntegrationTest
  # --- Full app -------------------------------------------------------------

  test "the tool is behind the chassis's door" do
    get "/projects"
    assert_redirected_to "/session/new"
  end

  test "signed in, the tool is a page of the chassis" do
    sign_in_as users(:one)
    get "/projects"

    assert_response :success
    assert_select "h1.page-title", "Projects"
    assert_select ".masthead__mark a", text: "Chassis"
    assert_select "nav.nav a[aria-current=page][href='/projects']", text: /Projects/
    assert_select "link[rel=stylesheet][href*='projects/components']"
  end

  # --- REST ------------------------------------------------------------------

  test "the API is behind the chassis's token, not its session" do
    get "/projects/api/v1/projects"
    assert_response :unauthorized

    sign_in_as users(:one)
    get "/projects/api/v1/projects"
    assert_response :unauthorized
  end

  test "the API describes itself to anyone" do
    get "/projects/api/v1/openapi"

    assert_response :success
    assert_equal "Projects", JSON.parse(response.body).dig("info", "title")
  end

  test "the API answers the chassis's token" do
    get "/projects/api/v1/projects", headers: bearer

    assert_response :success
    assert_kind_of Array, JSON.parse(response.body)
  end

  # --- Library ---------------------------------------------------------------

  test "the tool is readable through its public Ruby methods" do
    assert_kind_of Array, Projects.projects
    assert_nil Projects.project("nothing filed here")
  end

  # --- The tools together ----------------------------------------------------

  # The point of one process, and of the initializer. A palette written into
  # Pandatone over REST and a pattern composed in Stripeclub both turn up on a
  # project page, drawn, with nothing between them but a tag — and each links
  # back into the tool that holds it, because a project is a reference and
  # never a copy.
  test "a tagged palette and a tagged pattern are both on the project's page" do
    sign_in_as users(:one)
    write_palette "Brand Core", %w[ bobbymeyerdotcom ]
    write_pattern "Awning", "bobbymeyerdotcom"
    post "/projects", params: { project: { name: "bobbymeyer.com", tag: "bobbymeyerdotcom" } }

    get "/projects/bobbymeyerdotcom"

    assert_response :success
    assert_select "#source-palettes .card__name", text: "Brand Core"
    assert_select "#source-palettes a[href^='/pandatone/palettes/']"
    assert_select "#source-palettes .item__swatch", 2, "a palette is drawn as the strip it is"
    assert_select "#source-patterns .card__name", text: "Awning"
    assert_select "#source-patterns img[src$='/tile.svg']", 1
  end

  # The rule, through the real tools rather than a fake source.
  test "something tagged with both lands on the subproject and not on the top" do
    sign_in_as users(:one)
    write_palette "Site Core", %w[ bobbymeyerdotcom ]
    write_palette "Summer Warm", %w[ bobbymeyerdotcom 2026summer ]
    write_palette "Stray", %w[ 2026summer ]

    post "/projects", params: { project: { name: "bobbymeyer.com", tag: "bobbymeyerdotcom" } }
    site = Projects.projects.sole
    post "/projects", params: { project: { name: "Summer 2026", tag: "2026summer", parent_id: site[:id] } }

    get "/projects/bobbymeyerdotcom"
    assert_select "#source-palettes .card__name", text: "Site Core"
    assert_select "#source-palettes .card__name", { text: "Summer Warm", count: 0 }, "the subproject has it"
    assert_select ".subproject-card .card__meta", text: "#2026summer · 1 thing"

    get "/projects/2026summer"
    assert_select "#source-palettes .card__name", text: "Summer Warm"
    assert_select "#source-palettes .card__name", { text: "Stray", count: 0 },
      "a subproject narrows a project; its tag alone puts nothing anywhere"
  end

  # A colour is tagged in Pandatone the same way a palette is, and the seam
  # takes kinds rather than tools: two sources out of one engine.
  test "a project gathers two kinds from one tool" do
    sign_in_as users(:one)
    write_palette "Brand Core", %w[ bobbymeyerdotcom ], colors: [
      { name: "signal-red", hex: "#E30613", tags: %w[ bobbymeyerdotcom ] }
    ]
    post "/projects", params: { project: { name: "bobbymeyer.com", tag: "bobbymeyerdotcom" } }

    get "/projects/bobbymeyerdotcom"

    assert_select "#source-palettes .card__name", text: "Brand Core"
    assert_select "#source-colors .card__name", text: "signal-red"
    assert_select "#source-colors a[href^='/pandatone/colors/']"
  end

  # Every tool the chassis registered is asked, and named, even when it has
  # nothing: a project with an empty section reads as "nothing tagged there
  # yet", which is information.
  test "every registered source is asked, and says so when it has nothing" do
    sign_in_as users(:one)
    post "/projects", params: { project: { name: "Empty", tag: "nothingtagged" } }

    get "/projects/nothingtagged"

    assert_select "#source-palettes", 1
    assert_select "#source-colors", 1
    assert_select "#source-patterns", 1
    assert_select "#source-patterns .empty", /Nothing here carries #nothingtagged yet/
  end

  # A project holds nothing, so taking one away takes nothing with it.
  test "taking a project away leaves every tag exactly where it was" do
    sign_in_as users(:one)
    write_palette "Brand Core", %w[ bobbymeyerdotcom ]
    post "/projects", params: { project: { name: "bobbymeyer.com", tag: "bobbymeyerdotcom" } }

    delete "/projects/bobbymeyerdotcom"

    # The engine's own index helper, which is the mount path and a slash:
    # a route at an engine's root is written that way, and both reach it.
    assert_redirected_to "/projects/"
    assert_equal [ "Brand Core" ], Pandatone.palettes(tag: "bobbymeyerdotcom").map { |p| p[:name] }
  end

  private
    def bearer
      { "Authorization" => "Bearer #{users(:one).api_token}" }
    end

    # Pandatone refuses a value that is already in the library under another
    # name, so each palette gets its own two, derived from its name.
    def write_palette(name, tags, colors: nil)
      colors ||= [ { name: "#{name.parameterize}-1", hex: hex_for(name, 1) },
                   { name: "#{name.parameterize}-2", hex: hex_for(name, 2) } ]
      post "/pandatone/api/v1/palettes", headers: bearer, as: :json,
        params: { palette: { name: name, tags: tags, colors: colors } }
      assert_response :created
    end

    def hex_for(name, index)
      "#%06X" % (Digest::MD5.hexdigest("#{name}-#{index}")[0, 6].to_i(16))
    end

    def write_pattern(name, tag)
      post "/stripeclub/patterns", params: { pattern: { name: name, slot_count: 2, angle: 90, tag_list: tag } }
    end
end
