require "application_system_test_case"

class SignInTest < ApplicationSystemTestCase
  test "signing in lands on the bay, and signing out leaves it" do
    sign_in_as users(:one)

    assert_selector "h1", text: "Chassis"
    assert_selector ".empty", text: "Nothing is mounted yet"

    click_on "Sign out"

    assert_selector "h1", text: "Sign in"
  end

  test "the wrong password is refused on the page, not in a log" do
    visit new_session_path
    fill_in "Email", with: users(:one).email_address
    fill_in "Password", with: "wrong"
    click_on "Sign in"

    assert_selector "[role=alert]", text: "Try another email address or password."
  end
end
