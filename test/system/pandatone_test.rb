require "application_system_test_case"

class PandatoneTest < ApplicationSystemTestCase
  test "the tool is one click from the bay, inside the same shell" do
    sign_in_as users(:one)

    within("dl.pairs") { click_on "Pandatone" }

    assert_selector "h1", text: "Palettes"
    assert_selector ".masthead__mark", text: "Chassis"
    within(".subnav") { click_on "Colors" }
    assert_selector "h1", text: "Colors"

    within(".nav") { click_on "Account" }
    click_on "Sign out"
    assert_selector "h1", text: "Sign in"
  end
end
