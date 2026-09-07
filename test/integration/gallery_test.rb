require "test_helper"

# The gallery is the alignment made visible: the same screen of every tool,
# side by side, each frame the page the tool already serves.
class GalleryTest < ActionDispatch::IntegrationTest
  test "the gallery is behind the chassis's door" do
    get "/gallery"
    assert_redirected_to "/session/new"
  end

  test "the gallery frames the same screen of every tool" do
    sign_in_as users(:one)
    get "/gallery"

    assert_response :success
    assert_select "h1.page-title", "Gallery"
    assert_select "section.gallery", 3
    assert_select "section.gallery h2", text: "Index"
    Chassis::Engines.all.each do |mount|
      assert_select "iframe[src^='#{mount.path}/']", minimum: 2, message: "#{mount.name} is missing from the gallery"
    end
  end

  # A tool with nothing in it has nothing to dress; the frame says so rather
  # than opening a page that is not there.
  test "a tool with nothing to open says so" do
    sign_in_as users(:one)
    get "/gallery"

    assert_select "section.gallery:last-of-type .empty", minimum: 1
  end
end
