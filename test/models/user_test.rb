require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "a password is eight characters at least, and nothing else is asked of it" do
    user = User.new(email_address: "someone@example.com", password: "seven77")
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 8 characters)"

    user.password = "eight888"
    assert user.valid?
  end

  test "an account is issued an API token as it is made, and can trade it for a new one" do
    user = User.create!(email_address: "someone@example.com", password: "long enough")
    assert_match(/\A[A-Za-z0-9]{24}\z/, user.api_token)

    was = user.api_token
    user.regenerate_api_token
    assert_not_equal was, user.api_token
  end

  test "an address is held once" do
    user = User.new(email_address: users(:one).email_address.upcase, password: "long enough")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end
end
