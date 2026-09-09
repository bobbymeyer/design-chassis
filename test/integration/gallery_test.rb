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
    # The mount path, not the mount path and a slash. That assumed every
    # tool's index lives one level below its mount, which was true while every
    # tool had a noun to list; Projects lists projects, so its index is the
    # mount itself. What the assertion is for — every tool is framed here, on
    # more than one screen — is unchanged.
    Chassis::Engines.all.each do |mount|
      assert_select "iframe[src^='#{mount.path}']", minimum: 2, message: "#{mount.name} is missing from the gallery"
    end
  end

  # The editor is the last row: the start of a badge, the Compose surface
  # and the Dress surface, each the page Badger serves. The boards it was
  # drawn as have all left the row, each replaced by its page.
  test "the gallery frames the Badger editor as built" do
    sign_in_as users(:one)
    # A badge with no type in it: the row needs a badge to open, and the
    # type sidecar is not part of this suite.
    post "/badger/badges", params: { badge: { name: "Kiruna",
      spec_yaml: "shape: { kind: circle, radius: 80 }\nregions: [ { kind: rule, distance: 0, weight: 4 } ]\n" } }
    badge = Badger.badges.sole
    get "/gallery"

    assert_select "section.gallery:last-of-type h2", text: "Editor"
    assert_select "section.gallery:last-of-type iframe[src='/badger/badges/new']", 1
    assert_select "section.gallery:last-of-type iframe[src='/badger/badges/#{badge[:id]}']", 1
    assert_select "section.gallery:last-of-type iframe[src=?]", "/badger/badges/#{badge[:id]}?section=dress", 1
    assert_select "iframe[src^='/gallery/badger-editor']", 0, "nothing of the mockup is framed"
  end

  test "the mockup's boards are no longer served" do
    sign_in_as users(:one)
    get "/gallery/badger-editor/start"
    assert_response :not_found
  end

  # A tool with nothing in it has nothing to dress; the frame says so rather
  # than opening a page that is not there.
  test "a tool with nothing to open says so" do
    sign_in_as users(:one)
    get "/gallery"

    assert_select "section.gallery:nth-of-type(3) .empty", minimum: 1
    assert_select "section.gallery:last-of-type .empty", 2, "no badge, nothing to compose or dress; the start is still there"
    assert_select "section.gallery:last-of-type iframe[src='/badger/badges/new']", 1
  end
end
