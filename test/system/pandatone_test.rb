require "application_system_test_case"

class PandatoneTest < ApplicationSystemTestCase
  test "the tool is one click from the bay, inside the same shell" do
    sign_in_as users(:one)

    within(".masthead") { click_on "Pandatone" }

    assert_selector "h1", text: "Palettes"
    assert_selector ".masthead__mark", text: "Chassis"
    within(".nav") { click_on "Colors" }
    assert_selector "h1", text: "Colors"

    within(".nav") { click_on "Sign out" }
    assert_selector "h1", text: "Sign in"
  end
end
