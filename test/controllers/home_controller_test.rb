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

  test "the bay is a list, not an empty state, once something is mounted" do
    sign_in_as users(:one)
    get root_path

    assert_select ".empty", false
    assert_select "dl.pairs dt a[href='/pandatone']", "Pandatone"
    assert_select "dl.pairs dd", "/pandatone"
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
