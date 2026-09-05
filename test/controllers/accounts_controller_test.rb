require "test_helper"

# Who you are signed in as, and the credential your scripts carry.
class AccountsControllerTest < ActionDispatch::IntegrationTest
  test "the account is behind the door" do
    get account_path
    assert_redirected_to new_session_path
  end

  test "shows the address and the token" do
    sign_in_as users(:one)
    get account_path

    assert_response :success
    assert_select "h1", "Account"
    assert_select ".lede", /one@example\.com/
    assert_select "button.copy", users(:one).api_token
  end

  # Regenerating is the whole of revocation.
  test "regenerating the token retires the one before it" do
    sign_in_as users(:one)
    was = users(:one).api_token

    patch api_token_path

    assert_redirected_to account_path
    assert_not_equal was, users(:one).reload.api_token
  end
end
