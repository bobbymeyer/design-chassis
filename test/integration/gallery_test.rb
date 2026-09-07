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
    assert_select ".page-head label.choice input.gallery__fields[type=checkbox]", 1, "the fields can be drawn over every frame"
    assert_select "section.gallery", 4
    assert_select "section.gallery h2", text: "Index"
    Chassis::Engines.all.each do |mount|
      assert_select "iframe[src^='#{mount.path}/']", minimum: 2, message: "#{mount.name} is missing from the gallery"
    end
  end

  # The editor is weighed on the same page as the pages: the last row is the
  # two surfaces Badger serves and the one board of the design not yet built,
  # a bare page of the chassis's own.
  test "the gallery frames the Badger editor, built and as drawn" do
    sign_in_as users(:one)
    post "/badger/badges", params: { badge: { name: "Kiruna",
      spec_yaml: "shape: { kind: circle, radius: 80 }\nregions: [ { kind: rule, distance: 0, weight: 4 } ]\n" } }
    badge = Badger.badges.sole
    get "/gallery"

    assert_select "section.gallery:last-of-type h2", text: "Editor"
    assert_select "section.gallery:last-of-type iframe[src='/badger/badges/#{badge[:id]}']", 1
    assert_select "section.gallery:last-of-type iframe[src=?]", "/badger/badges/#{badge[:id]}?section=dress", 1
    assert_select "section.gallery:last-of-type iframe[src='/gallery/badger-editor/start']", 1
    assert_select "section.gallery:last-of-type iframe[src='/gallery/badger-editor/compose']", 0, "the built page stands in for its board"
  end

  test "a board is the mockup in a page that declares the typeface and nothing else" do
    sign_in_as users(:one)
    get "/gallery/badger-editor/dress"

    assert_response :success
    assert_select "style", text: /Archivo/
    assert_select ".masthead", 0
    assert_select "h1", text: "Stockholm Stadion"
    assert_select "img[src='/gallery/badger-editor/stockholm.jpg']", 1

    get "/gallery/badger-editor/stockholm.jpg"
    assert_response :success
    assert_equal "image/jpeg", response.media_type
  end

  test "there are three boards and no others" do
    sign_in_as users(:one)
    get "/gallery/badger-editor/inspector"
    assert_response :not_found
  end

  # A tool with nothing in it has nothing to dress; the frame says so rather
  # than opening a page that is not there.
  test "a tool with nothing to open says so" do
    sign_in_as users(:one)
    get "/gallery"

    assert_select "section.gallery:nth-of-type(3) .empty", minimum: 1
    assert_select "section.gallery:last-of-type .empty", 2, "no badge, no editor to open; the board is still drawn"
    assert_select "section.gallery:last-of-type iframe[src='/gallery/badger-editor/start']", 1
  end
end
