require "test_helper"

# rack_test by default: no browser, no CSS, no JavaScript, and fast. Set
# SYSTEM_TEST_DRIVER=selenium to drive a real Chrome, which is what CI does
# in its browser job.
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  if ENV["SYSTEM_TEST_DRIVER"] == "selenium"
    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
  else
    driven_by :rack_test
  end

  def sign_in_as(user)
    visit new_session_path
    fill_in "Email", with: user.email_address
    fill_in "Password", with: "password"
    click_on "Sign in"
  end
end
