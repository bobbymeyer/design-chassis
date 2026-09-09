require "application_system_test_case"

# A project, in a browser: the tool is one click from the bay, and what it
# gathered is drawn rather than listed.
class ProjectsTest < ApplicationSystemTestCase
  test "a project is one click from the bay and draws what it gathered" do
    sign_in_as users(:one)

    within("dl.pairs") { click_on "Projects" }

    assert_selector "h1", text: "Projects"
    assert_selector ".masthead__mark", text: "Chassis"

    click_on "Start a project"
    fill_in "Name", with: "bobbymeyer.com"
    fill_in "Tag", with: "bobbymeyerdotcom"
    click_on "Start it"

    assert_selector "h1", text: "bobbymeyer.com"
    assert_selector ".project-line", text: "#bobbymeyerdotcom"
    # Every registered tool is asked and named, even with nothing to show.
    assert_selector "#source-palettes h2", text: "Palettes"
    assert_selector "#source-patterns h2", text: "Patterns"
  end
end
