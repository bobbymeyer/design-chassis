require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "the root is behind the door" do
    get root_path
    assert_redirected_to new_session_path
  end

  test "signed in, the root is the bay" do
    sign_in_as users(:one)
    get root_path

    assert_response :success
    assert_select "h1", "Chassis"
  end

  test "an empty bay says so rather than showing nothing" do
    sign_in_as users(:one)
    get root_path

    assert_select ".empty", /Nothing is mounted yet/
  end

  test "the bay lists every mounted engine by name, linked to its path" do
    sign_in_as users(:one)
    get root_path

    assert_response :success
    Chassis::Engines.all.each do |mount|
      assert_select "a[href=?]", mount.path, text: mount.name
    end
  end
end
