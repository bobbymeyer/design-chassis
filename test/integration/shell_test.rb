require "test_helper"

# What every page of the chassis is wrapped in. The shell itself is
# its-swiss's; these guard what the chassis puts in its slots and that the
# slots are filled at all.
class ShellTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
    get root_path
  end

  test "pages transition rather than cut" do
    assert_select "meta[name=view-transition][content=same-origin]"
  end

  test "the type is its-swiss's, then the chassis's own theme, in that order" do
    assert_select "link[rel=stylesheet][href*='its_swiss/tokens']"
    assert_select "link[rel=stylesheet][href*='/theme']"
    assert_select "link[rel=stylesheet]" do |links|
      hrefs = links.map { |link| link["href"] }
      assert_operator hrefs.index { |h| h.include?("its_swiss/") }, :<, hrefs.index { |h| h.include?("/theme") }
    end
  end

  test "the mark names the chassis and goes home" do
    assert_select ".masthead__mark a[href=?]", root_path, text: "Chassis"
  end

  test "the mark carries the knobs, and a screen reader is spared them" do
    assert_select ".masthead__mark .masthead__knobs[aria-hidden=true]", text: "🎛️"
    assert_select ".masthead__mark", text: /\A\s*🎛️\s*Chassis\s*\z/
  end

  test "the nav is the engine list, and a way out" do
    assert_select "nav.nav" do
      Chassis::Engines.all.each do |mount|
        assert_select "a[href=?]", mount.path, text: mount.name
      end
      assert_select "form[action=?] button", session_path, text: "Sign out"
    end
  end

  test "a keyboard can skip the masthead" do
    assert_select "a.skip-link[href='#main']"
  end

  test "the title is the page's, then the chassis's" do
    assert_select "title", "Chassis"

    get new_session_path
    assert_select "title", "Sign in"
  end

  test "nothing here is Tailwind" do
    assert_select "script[src*=tailwind]", false
    assert_select "[class*='flex-'], [class*='px-'], [class*='text-gray']", false
  end
end
