require "test_helper"

# The second engine, mounted, reachable the same three ways as the first —
# a full application at its path, a REST API behind the chassis's token, and
# a library through its public methods.
#
# What is new here is that this one consumes another tool. Stripeclub asks
# Pandatone for palettes, and in this process the asking is a method call
# rather than a request; the last section is what holds those two together.
class StripeclubTest < ActionDispatch::IntegrationTest
  # --- Full app -------------------------------------------------------------

  test "the tool is behind the chassis's door" do
    get "/stripeclub"
    assert_redirected_to "/session/new"
  end

  test "signed in, the tool is a page of the chassis" do
    sign_in_as users(:one)
    get "/stripeclub"

    assert_response :success
    assert_select "h1", "Patterns"
    # The chassis's shell around the engine's page.
    assert_select ".masthead__mark a", text: "Chassis"
    assert_select "nav.nav a[aria-current=page][href='/stripeclub']", text: "Stripeclub"
    # The engine's own stylesheet, through the chassis's head.
    assert_select "link[rel=stylesheet][href*='stripeclub/components']"
  end

  # The sibling stays reachable and unselected: two engines mounted at once
  # is the thing the chassis was built for, and the nav is where it shows.
  test "both tools are in the nav, and only the one being looked at is current" do
    sign_in_as users(:one)
    get "/stripeclub"

    assert_select "nav.nav a[href='/pandatone']", text: "Pandatone"
    assert_select "nav.nav a[href='/pandatone'][aria-current]", false
  end

  test "the chassis's route helpers still point at the chassis from inside the tool" do
    sign_in_as users(:one)
    get "/stripeclub"

    assert_select "nav.nav form[action='/session'] button", text: "Sign out"
    assert_select "nav.nav a[href='/account']", text: "Account"
  end

  # --- REST ------------------------------------------------------------------

  test "the API is behind the chassis's token, not its session" do
    get "/stripeclub/api/v1/patterns"
    assert_response :unauthorized

    sign_in_as users(:one)
    get "/stripeclub/api/v1/patterns"
    assert_response :unauthorized
  end

  test "the API describes itself to anyone" do
    get "/stripeclub/api/v1/openapi"

    assert_response :success
    assert_equal "Stripeclub", JSON.parse(response.body).dig("info", "title")
  end

  test "the API answers the chassis's token" do
    get "/stripeclub/api/v1/patterns", headers: bearer

    assert_response :success
    assert_kind_of Array, JSON.parse(response.body)
  end

  # --- Library ---------------------------------------------------------------

  test "the tool is readable through its public Ruby methods" do
    assert_kind_of Array, Stripeclub.patterns
    assert_nil Stripeclub.pattern("Nothing Here")
  end

  # --- The two tools together ------------------------------------------------

  # The point of one process. Stripeclub knows Pandatone by its wire format
  # and by nothing else, so this is the whole of the contract between them:
  # what config/initializers/stripeclub.rb hands over has to be what
  # Pandatone's API would have sent, down to the shape of the keys.
  #
  # String keys, because the wire format is JSON's and that is the contract
  # the engine publishes. It would in fact cope with symbols — it normalizes
  # what it is handed — but that is a tolerance inside the engine, not a
  # promise, and this test pins the chassis to the promise.
  test "the palettes Stripeclub is handed are Pandatone's, in Pandatone's wire format" do
    post "/pandatone/api/v1/palettes", headers: bearer, as: :json, params: {
      palette: { name: "Brand Core", tags: %w[ brand active ],
                 colors: [ { name: "signal-red", hex: "#E30613" },
                           { name: "ink-black", hex: "#111111" } ] }
    }
    assert_response :created

    palettes = Stripeclub.palette_source.call
    palette = palettes.sole

    assert_equal %w[ id name tags colors ].sort, palette.keys.sort
    assert_equal "Brand Core", palette["name"]
    assert_equal %w[ brand active ], palette["tags"]

    # Summaries carry no colors, so a source that only listed would hand over
    # palettes with nothing in them. These are the full reads.
    assert_equal [ "signal-red", "ink-black" ], palette["colors"].map { |color| color["name"] }
    assert_equal [ "#E30613", "#111111" ], palette["colors"].map { |color| color["hex"] }
  end

  # Deep, not shallow: the channels are a hash inside a hash inside an array,
  # and it is the innermost one the engine reaches into to rank a palette by
  # how light each color looks. A shallow conversion would satisfy the test
  # above and still not be the wire format.
  test "the wire format is string-keyed all the way down" do
    post "/pandatone/api/v1/palettes", headers: bearer, as: :json,
      params: { palette: { name: "Brand Core", colors: [ { name: "signal-red", hex: "#E30613" } ] } }

    color = Stripeclub.palette_source.call.sole["colors"].sole

    assert_equal Pandatone.palette("Brand Core")[:colors].sole[:rgb].transform_keys(&:to_s), color["rgb"]
    assert color["rgb"].keys.all?(String), "the channels arrived as #{color["rgb"].keys.inspect}"
  end

  test "a palette the chassis has none of is an empty catalogue, not an error" do
    assert_equal [], Stripeclub.palette_source.call
  end

  private
    def bearer
      { "Authorization" => "Bearer #{users(:one).api_token}" }
    end
end
