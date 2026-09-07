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
    assert_select "nav.nav a[aria-current=page][href='/stripeclub']", text: /Stripeclub/
    # The engine's own stylesheet, through the chassis's head.
    assert_select "link[rel=stylesheet][href*='stripeclub/components']"
    assert_select "link[rel=stylesheet][href*='pandatone/dresser']"
    assert_select "header.page-head h1.page-title", text: "Patterns"
  end

  # The sibling stays reachable and unselected: two engines mounted at once
  # is the thing the chassis was built for, and the nav is where it shows.
  test "both tools are in the nav, and only the one being looked at is current" do
    sign_in_as users(:one)
    get "/stripeclub"

    assert_select "nav.nav a[href='/pandatone']", text: /Pandatone/
    assert_select "nav.nav a[href='/pandatone'][aria-current]", false
  end

  test "the chassis's route helpers still point at the chassis from inside the tool" do
    sign_in_as users(:one)
    get "/stripeclub"

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

  # The point of one process. Stripeclub dresses a pattern through Pandatone's
  # own dresser, which with no PANDATONE_URL asks the Pandatone in this
  # process through its public methods — so a palette written into Pandatone
  # over REST is on Stripeclub's picker with nothing in the chassis between
  # them. The chassis used to hand over a lambda; it hands over nothing now,
  # and this is the test that it need not.
  test "a palette written into Pandatone is on Stripeclub's picker, on the ladder" do
    post "/pandatone/api/v1/palettes", headers: bearer, as: :json, params: {
      palette: { name: "Brand Core", tags: %w[ brand active ],
                 colors: [ { name: "signal-red", hex: "#E30613" }, { name: "ink-black", hex: "#111111" } ] }
    }
    assert_response :created

    sign_in_as users(:one)
    post "/stripeclub/patterns", params: { pattern: { name: "Awning", slot_count: 2, angle: 90 } }
    pattern = Stripeclub.patterns.sole

    get "/stripeclub/patterns/#{pattern[:id]}/colorways/new?refresh=1"

    assert_response :success
    assert_select "section.palettes:first-of-type tbody tr", 1
    assert_select "section.palettes:first-of-type td", text: "Brand Core"
    greys = css_select(".palette-swatch").map { |swatch| swatch["style"][/#\h{6}/] }
    assert_equal 2, greys.size
    assert_equal greys.sort.reverse, greys, "the strip runs lightest first"
    assert_not_includes greys, "#E30613", "the picker shows value, not hue"
  end

  test "a Pandatone with no palettes is an empty picker, not an error" do
    sign_in_as users(:one)
    post "/stripeclub/patterns", params: { pattern: { name: "Awning", slot_count: 2, angle: 90 } }
    pattern = Stripeclub.patterns.sole

    get "/stripeclub/patterns/#{pattern[:id]}/colorways/new?refresh=1"

    assert_response :success
    assert_select "section.palettes .empty", text: "None."
  end

  private
    def bearer
      { "Authorization" => "Bearer #{users(:one).api_token}" }
    end
end
