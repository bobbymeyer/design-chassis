require "test_helper"

# The third engine, mounted, reachable the same three ways as the others —
# a full application at its path, a REST API behind the chassis's token, and
# a library through its public methods — and consuming Pandatone the way
# Stripeclub does, through the wire format and nothing else.
class BadgerTest < ActionDispatch::IntegrationTest
  # --- Full app -------------------------------------------------------------

  test "the tool is behind the chassis's door" do
    get "/badger"
    assert_redirected_to "/session/new"
  end

  test "signed in, the tool is a page of the chassis" do
    sign_in_as users(:one)
    get "/badger"

    assert_response :success
    assert_select "h1", "Badges"
    assert_select ".masthead__mark a", text: "Chassis"
    assert_select "nav.nav a[aria-current=page][href='/badger']", text: "Badger"
    assert_select "link[rel=stylesheet][href*='badger/components']"
  end

  test "the other tools stay in the nav, unselected" do
    sign_in_as users(:one)
    get "/badger"

    assert_select "nav.nav a[href='/pandatone']", text: "Pandatone"
    assert_select "nav.nav a[href='/stripeclub'][aria-current]", false
  end

  # --- REST ------------------------------------------------------------------

  test "the API is behind the chassis's token, not its session" do
    get "/badger/api/v1/badges"
    assert_response :unauthorized

    sign_in_as users(:one)
    get "/badger/api/v1/badges"
    assert_response :unauthorized
  end

  test "the API describes itself to anyone" do
    get "/badger/api/v1/openapi"

    assert_response :success
    assert_equal "Badger", JSON.parse(response.body).dig("info", "title")
  end

  test "the API answers the chassis's token" do
    get "/badger/api/v1/badges", headers: bearer

    assert_response :success
    assert_kind_of Array, JSON.parse(response.body)
  end

  # --- Library ---------------------------------------------------------------

  test "the tool is readable through its public Ruby methods" do
    assert_kind_of Array, Badger.badges
    assert_nil Badger.badge("Nothing Here")
  end

  # --- The fonts and the sidecar ---------------------------------------------

  # The shell's own typeface is what badges are set in: no second copy of a
  # font in the repository, and the sidecar unwraps the woff2 itself.
  test "the badge fonts are the chassis's own" do
    assert_includes Badger::Fonts.names, "archivo-variable-latin"
  end

  # --- The two tools together ------------------------------------------------

  test "the palettes Badger is handed are Pandatone's, in Pandatone's wire format" do
    post "/pandatone/api/v1/palettes", headers: bearer, as: :json, params: {
      palette: { name: "Brand Core", tags: %w[ brand active ],
                 colors: [ { name: "signal-red", hex: "#E30613" }, { name: "ink-black", hex: "#111111" } ] }
    }
    assert_response :created

    palette = Badger.palette_source.call.sole
    assert_equal %w[ id name tags colors ].sort, palette.keys.sort
    assert_equal "Brand Core", palette["name"]
    assert_equal [ "#E30613", "#111111" ], palette["colors"].map { |color| color["hex"] }
    assert palette["colors"].first["rgb"].keys.all?(String), "the channels are string-keyed, all the way down"
  end

  test "a palette the chassis has none of is an empty catalogue, not an error" do
    assert_equal [], Badger.palette_source.call
  end

  private
    def bearer
      { "Authorization" => "Bearer #{users(:one).api_token}" }
    end
end
