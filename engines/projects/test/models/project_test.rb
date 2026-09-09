require "test_helper"

module Projects
  # A project is a name and a tag, and optionally a parent. Everything else
  # about it is a question asked of the tools around it.
  class ProjectTest < ActiveSupport::TestCase
    test "a project is a name and a tag" do
      project = Project.create!(name: "bobbymeyer.com", tag: "bobbymeyerdotcom")

      assert_nil project.parent
      assert_equal "bobbymeyerdotcom", project.to_param
    end

    test "the tag is stripped and downcased, so it is written one way" do
      assert_equal "bobbymeyerdotcom", Project.create!(name: "Site", tag: "  BobbyMeyerDotCom ").tag
    end

    test "a project needs a name and a tag" do
      project = Project.new

      assert_not project.valid?
      assert_includes project.errors[:name], "can't be blank"
      assert_includes project.errors[:tag], "can't be blank"
    end

    # A tag is one word because that is what a tag is everywhere else in the
    # family: whole-word matching, downcased, no separator inside it.
    test "a tag is one word" do
      assert_not Project.new(name: "Site", tag: "two words").valid?
      assert_not Project.new(name: "Site", tag: "one,two").valid?
      assert Project.new(name: "Site", tag: "2026summer").valid?
    end

    test "a tag means one thing, wherever in the tree it is written" do
      Project.create!(name: "Site", tag: "print")
      twin = Project.new(name: "Print work", tag: "PRINT")

      assert_not twin.valid?
      assert_includes twin.errors[:tag], "has already been taken"
    end

    # --- The tree -------------------------------------------------------

    test "a subproject knows the whole line of tags above it" do
      site = Project.create!(name: "bobbymeyer.com", tag: "bobbymeyerdotcom")
      summer = Project.create!(name: "Summer 2026", tag: "2026summer", parent: site)
      posters = Project.create!(name: "Posters", tag: "posters", parent: summer)

      assert_equal %w[ bobbymeyerdotcom ], site.required_tags
      assert_equal %w[ bobbymeyerdotcom 2026summer ], summer.required_tags
      assert_equal %w[ bobbymeyerdotcom 2026summer posters ], posters.required_tags
      assert_equal [ site, summer ], posters.ancestors
      assert_equal 2, posters.depth
    end

    test "a project cannot be its own parent, or its own grandparent" do
      site = Project.create!(name: "Site", tag: "site")
      summer = Project.create!(name: "Summer", tag: "summer", parent: site)

      site.parent = site
      assert_not site.valid?
      assert_includes site.errors[:parent], "cannot be the project itself"

      site.parent = summer
      assert_not site.valid?
      assert_includes site.errors[:parent], "cannot be one of its own subprojects"
    end

    # Nothing goes while something still points at it, which is the same rule
    # a Stripeclub value is removed under.
    test "a project with subprojects will not go on its own" do
      site = Project.create!(name: "Site", tag: "site")
      Project.create!(name: "Summer", tag: "summer", parent: site)

      assert_not site.destroy
      assert_includes site.errors[:base], "Cannot delete record because dependent children exist"
      assert Project.exists?(site.id)
    end

    test "the tree reads as a flat list, each project under the one above it" do
      site = Project.create!(name: "bobbymeyer.com", tag: "bobbymeyerdotcom")
      summer = Project.create!(name: "Summer 2026", tag: "2026summer", parent: site)
      Project.create!(name: "Posters", tag: "posters", parent: summer)
      Project.create!(name: "Archive", tag: "archive")

      assert_equal [ "Archive", "bobbymeyer.com", "Summer 2026", "Posters" ],
        Project.in_tree_order.map(&:name)
    end
  end
end
