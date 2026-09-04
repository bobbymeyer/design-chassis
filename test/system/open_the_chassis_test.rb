require "application_system_test_case"

# The first visit to an empty chassis, through the form as a person would.
# The controller test posts what the form posts; this one proves the form
# posts it.
class OpenTheChassisTest < ApplicationSystemTestCase
  setup do
    Session.delete_all
    User.delete_all
  end

  test "the first visitor makes the account and is let in" do
    visit root_path
    assert_selector "h1", text: "Open the chassis"

    fill_in "Email", with: "first@example.com"
    fill_in "Password", with: "long enough"
    click_on "Open the chassis"

    assert_selector "h1", text: "Chassis"
    assert_selector ".footer", text: "Signed in as first@example.com"
  end

  test "a short password is refused beside the field, with the form still filled" do
    visit new_registration_path
    fill_in "Email", with: "first@example.com"
    fill_in "Password", with: "short"
    click_on "Open the chassis"

    assert_selector "[role=alert]", text: "1 problem stopped this being saved."
    assert_selector ".field--invalid", text: "Password is too short"
    assert_field "Email", with: "first@example.com"
  end
end
