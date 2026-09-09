require "test_helper"

# The public interface: what another tool calls. Plain data out, never a
# record of the engine's, and the same hashes the API serializes.
class ProjectsTest < ActiveSupport::TestCase
  setup do
    @site = Projects::Project.create!(name: "bobbymeyer.com", tag: "bobbymeyerdotcom")
    @summer = Projects::Project.create!(name: "Summer 2026", tag: "2026summer", parent: @site)
    source { |_tag| [ item("Brand Core", %w[ bobbymeyerdotcom ]), item("Poster", %w[ bobbymeyerdotcom 2026summer ]) ] }
  end

  test "it has a version number" do
    assert Projects::VERSION
  end

  test "projects are summaries, the tree flat" do
    assert_equal [ "bobbymeyer.com", "Summer 2026" ], Projects.projects.map { |p| p[:name] }
    assert_equal %i[ id name tag note parent depth ], Projects.projects.first.keys
    assert_equal "bobbymeyerdotcom", Projects.projects.second[:parent]
  end

  test "a project is found by tag or by id, with what it gathers, or is nil" do
    assert_equal "bobbymeyer.com", Projects.project("bobbymeyerdotcom")[:name]
    assert_equal Projects.project("bobbymeyerdotcom"), Projects.project(@site.id)
    assert_nil Projects.project("nothing filed here")

    assert_equal [ "2026summer" ], Projects.project("bobbymeyerdotcom")[:subprojects]
    assert_equal [ "Brand Core" ], Projects.project("bobbymeyerdotcom")[:items].map { |i| i[:name] }
    assert_equal [ "Poster" ], Projects.project("2026summer")[:items].map { |i| i[:name] }
  end

  test "an item says which tool it came from and where to read it properly" do
    gathered = Projects.items("bobbymeyerdotcom").sole

    assert_equal %i[ source id name tags path ], gathered.keys
    assert_equal "things", gathered[:source]
    assert_equal "/things/Brand Core", gathered[:path]
    assert_nil Projects.items("nothing filed here")
  end

  test "the sources registered, named the way the interface names them" do
    assert_equal [ { key: :things, name: "Things", mark: nil } ], Projects.registered_sources
  end

  # Nothing that comes back is one of the engine's own objects.
  test "answers with hashes, strings and numbers only" do
    [ Projects.projects, Projects.project("bobbymeyerdotcom"), Projects.items("bobbymeyerdotcom") ].each do |answer|
      assert_nothing_raised { JSON.generate(answer) }
    end
  end
end
