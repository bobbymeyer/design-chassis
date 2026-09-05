require "test_helper"

# One account, made by whoever arrives first at an empty chassis. After that
# the door is shut: this is a tool for one person, and a second account is a
# console away if that ever changes.
class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  class WhileEmpty < RegistrationsControllerTest
    setup do
      Session.delete_all
      User.delete_all
    end

    test "the root sends the first visitor to make the account, not to a sign-in that cannot admit them" do
      get root_path
      assert_redirected_to new_registration_path
    end

    test "sign in also sends them to make the account" do
      get new_session_path
      assert_redirected_to new_registration_path
    end

    test "new" do
      get new_registration_path
      assert_response :success
      assert_select "form[action=?]", registration_path
    end

    test "create makes the account, signs it in and lands on the bay" do
      assert_difference "User.count", 1 do
        post registration_path, params: { user: { email_address: "first@example.com", password: "long enough" } }
      end

      assert_redirected_to root_path
      assert cookies[:session_id]
    end

    test "create refuses a short password and says why" do
      assert_no_difference "User.count" do
        post registration_path, params: { user: { email_address: "first@example.com", password: "short" } }
      end

      assert_response :unprocessable_content
      assert_select "[role=alert]", /Password/
    end
  end

  class OnceOpened < RegistrationsControllerTest
    test "new is shut" do
      get new_registration_path
      assert_redirected_to new_session_path
    end

    test "create is shut, whatever is posted" do
      assert_no_difference "User.count" do
        post registration_path, params: { user: { email_address: "second@example.com", password: "long enough" } }
      end

      assert_redirected_to new_session_path
    end

    test "the root sends a visitor to sign in" do
      get root_path
      assert_redirected_to new_session_path
    end
  end
end
