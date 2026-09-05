require "test_helper"

# The vertical slice: one engine, mounted, reachable three ways — as a full
# application at its path, as a REST API behind the chassis's token, and as
# a library through its public method. This is what the migration was for.
class PandatoneTest < ActionDispatch::IntegrationTest
  # --- Full app -------------------------------------------------------------

  test "the tool is behind the chassis's door" do
    get "/pandatone"
    assert_redirected_to "/session/new"
  end

  test "signed in, the tool is a page of the chassis" do
    sign_in_as users(:one)
    get "/pandatone"

    assert_response :success
    assert_select "h1", "Palettes"
    # The chassis's shell around the engine's page.
    assert_select ".masthead__mark a", text: "Chassis"
    assert_select "nav.nav a[aria-current=page][href='/pandatone']", text: "Pandatone"
    # The engine's sections, placed in the chassis's nav.
    assert_select "nav.nav a", text: "Colors"
    assert_select "nav.nav a", text: "Lookup"
    # The engine's own stylesheet, through the chassis's head.
    assert_select "link[rel=stylesheet][href*='pandatone/components']"
  end

  # Literal paths: after a request into the engine, this session's own
  # helpers carry the engine's script name, which is the very confusion the
  # layout has to avoid.
  test "the chassis's route helpers still point at the chassis from inside the tool" do
    sign_in_as users(:one)
    get "/pandatone"

    assert_select "nav.nav form[action='/session'] button", text: "Sign out"
    assert_select "nav.nav a[href='/account']", text: "Account"
  end

  # --- REST ------------------------------------------------------------------

  test "the API is behind the chassis's token, not its session" do
    get "/pandatone/api/v1/palettes"
    assert_response :unauthorized
    assert_equal({ "error" => "Unauthorized" }, JSON.parse(response.body))

    sign_in_as users(:one)
    get "/pandatone/api/v1/palettes"
    assert_response :unauthorized
  end

  test "the API describes itself to anyone" do
    get "/pandatone/api/v1/openapi"

    assert_response :success
    assert_equal "Pandatone", JSON.parse(response.body).dig("info", "title")
  end

  test "a palette written over REST is read back over REST" do
    post "/pandatone/api/v1/palettes", headers: bearer, as: :json, params: {
      palette: { name: "Brand Core", tags: %w[ brand active ],
                 colors: [ { name: "signal-red", hex: "#E30613" }, { name: "ink-black", hex: "#111111" } ] }
    }
    assert_response :created

    get "/pandatone/api/v1/palettes", headers: bearer, params: { tag: "active" }
    assert_equal [ "Brand Core" ], JSON.parse(response.body).map { |palette| palette["name"] }
  end

  # --- Library ---------------------------------------------------------------

  # Step 5 of the migration: one consumer, calling the public method only.
  # The chassis holds no record of the engine's; it holds a hash.
  test "the same palette is read through the public Ruby method" do
    post "/pandatone/api/v1/palettes", headers: bearer, as: :json,
      params: { palette: { name: "Brand Core", colors: [ { name: "signal-red", hex: "#E30613" } ] } }

    palette = Pandatone.palette("Brand Core")

    assert_kind_of Hash, palette
    assert_equal "Brand Core", palette[:name]
    assert_equal [ "#E30613" ], palette[:colors].map { |color| color[:hex] }
    assert_nil Pandatone.palette("Nothing Here")
    assert_equal [ "Brand Core" ], Pandatone.palettes(containing: "#E30613").map { |p| p[:name] }
  end

  private
    def bearer
      { "Authorization" => "Bearer #{users(:one).api_token}" }
    end
end
