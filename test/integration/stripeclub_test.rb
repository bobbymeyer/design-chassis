require "test_helper"

# The second engine, and the first time two tools meet. Stripeclub is mounted
# the way Pandatone is; what is new is that a Stripeclub pattern is dressed
# in a Pandatone palette without either tool knowing the other is in the
# room — the chassis hands Pandatone's public interface to Stripeclub's
# palette source, and that is all the orchestration there is.
class StripeclubTest < ActionDispatch::IntegrationTest
  test "the tool is behind the chassis's door" do
    get "/stripeclub"
    assert_redirected_to "/session/new"
  end

  test "signed in, the tool is a page of the chassis with its section in the nav" do
    sign_in_as users(:one)
    get "/stripeclub"

    assert_response :success
    assert_select "h1", "Patterns"
    assert_select ".masthead__mark a", text: "Chassis"
    assert_select "nav.nav a[aria-current=page][href='/stripeclub']", text: "Stripeclub"
    assert_select "nav.nav a", text: "Patterns"
    assert_select "nav.nav a[href='/pandatone']", text: "Pandatone"
    assert_select "link[rel=stylesheet][href*='stripeclub/components']"
  end

  test "the API is behind the chassis's token and describes itself to anyone" do
    get "/stripeclub/api/v1/patterns"
    assert_response :unauthorized

    get "/stripeclub/api/v1/patterns", headers: bearer
    assert_response :success

    get "/stripeclub/api/v1/openapi"
    assert_equal "Stripeclub", JSON.parse(response.body).dig("info", "title")
  end

  # The slice through both tools. A palette made in Pandatone over REST; a
  # pattern composed in Stripeclub through its form; the picker offers the
  # palette, having asked nothing over the network; the colorway that
  # results carries Pandatone's colours, read back through Stripeclub's
  # public method.
  test "a Pandatone palette dresses a Stripeclub pattern, in process" do
    post "/pandatone/api/v1/palettes", headers: bearer, as: :json, params: {
      palette: { name: "Deck Chair", colors: [ { name: "signal-red", hex: "#C1272D" }, { name: "cream", hex: "#FAF8F4" } ] }
    }
    assert_response :created

    sign_in_as users(:one)
    post "/stripeclub/patterns", params: { pattern: { name: "Awning", slot_count: 2, angle: 90 } }
    pattern = Stripeclub.patterns.find { |p| p[:name] == "Awning" }
    assert pattern, "the pattern was not composed"

    get "/stripeclub/patterns/#{pattern[:id]}/colorways/new"
    assert_response :success
    assert_select "main", /Deck Chair/

    palette_id = Pandatone.palette("Deck Chair")[:id]
    post "/stripeclub/patterns/#{pattern[:id]}/colorways", params: { palette_id: palette_id }
    assert_redirected_to "/stripeclub/patterns/#{pattern[:id]}"

    colorway = Stripeclub.pattern(pattern[:id])[:colorways].first
    assert_equal palette_id, colorway[:palette_id]
    assert_equal [ "#FAF8F4", "#C1272D" ], Stripeclub.colorway(colorway[:id])[:colors]
  end

  private
    def bearer
      { "Authorization" => "Bearer #{users(:one).api_token}" }
    end
end
