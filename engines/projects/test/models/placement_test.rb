require "test_helper"

module Projects
  # The rule, on its own: an item lands on the deepest project whose tags it
  # all carries. Everything else in this engine is arranging what this
  # decides.
  class PlacementTest < ActiveSupport::TestCase
    setup do
      @site = Project.create!(name: "bobbymeyer.com", tag: "bobbymeyerdotcom")
      @summer = Project.create!(name: "Summer 2026", tag: "2026summer", parent: @site)
    end

    test "something carrying only the project's tag is the project's" do
      with_items("masthead" => %w[ bobbymeyerdotcom ])

      assert_equal [ "masthead" ], @site.items.map(&:name)
      assert_empty @summer.items
    end

    # The case the whole shape was drawn for.
    test "something carrying both lands on the subproject, not the top" do
      with_items("poster" => %w[ bobbymeyerdotcom 2026summer ])

      assert_empty @site.items, "the top level does not keep what a subproject claims"
      assert_equal [ "poster" ], @summer.items.map(&:name)
    end

    # The other half of the same rule, and the one that is easy to get wrong:
    # a subproject narrows a project, it does not stand on its own.
    test "something carrying only the subproject's tag is in neither" do
      with_items("stray" => %w[ 2026summer ])

      assert_empty @site.items
      assert_empty @summer.items
    end

    test "something carrying neither tag is nowhere near" do
      with_items("unrelated" => %w[ archive ])

      assert_empty @site.items
      assert_empty @summer.items
    end

    test "extra tags do not disqualify anything" do
      with_items("poster" => %w[ bobbymeyerdotcom 2026summer print draft ])

      assert_equal [ "poster" ], @summer.items.map(&:name)
    end

    test "the deepest is the deepest, however far down it goes" do
      posters = Project.create!(name: "Posters", tag: "posters", parent: @summer)

      with_items("one" => %w[ bobbymeyerdotcom ],
                 "two" => %w[ bobbymeyerdotcom 2026summer ],
                 "three" => %w[ bobbymeyerdotcom 2026summer posters ])

      assert_equal [ "one" ], @site.items.map(&:name)
      assert_equal [ "two" ], @summer.items.map(&:name)
      assert_equal [ "three" ], posters.items.map(&:name)
    end

    # Two subprojects at the same depth are not a tie to be broken. Something
    # carrying both lines belongs to both, and hiding it from one of them
    # would be an answer nobody asked for.
    test "something claimed by two subprojects at the same depth is in both" do
      print = Project.create!(name: "Print", tag: "print", parent: @site)

      with_items("poster" => %w[ bobbymeyerdotcom 2026summer print ])

      assert_empty @site.items
      assert_equal [ "poster" ], @summer.items.map(&:name)
      assert_equal [ "poster" ], print.items.map(&:name)
    end

    test "a project gathers from every source, and says which is which" do
      Projects.source(:palettes, name: "Palettes") { |tag| [ item("brand", %w[ bobbymeyerdotcom ]) ] }
      Projects.source(:patterns, name: "Patterns") { |tag| [ item("awning", %w[ bobbymeyerdotcom ]) ] }

      assert_equal %i[ palettes patterns ], @site.readings.map { |reading| reading.source.key }
      assert_equal [ "brand", "awning" ], @site.items.map(&:name)
    end

    # A project of four tools should still show the three that answered.
    test "a source that raises is a source that is down, not a broken page" do
      Projects.source(:palettes, name: "Palettes") { |tag| [ item("brand", %w[ bobbymeyerdotcom ]) ] }
      Projects.source(:patterns, name: "Patterns") { |tag| raise IOError, "nobody home" }

      readings = @site.readings

      assert_equal [ "brand" ], @site.items.map(&:name)
      assert_not readings.first.down?
      assert readings.second.down?
      assert_match "nobody home", readings.second.error
    end

    test "no sources at all is a project with nothing in it, not an error" do
      Projects.sources_reset!

      assert_empty @site.items
      assert_empty @site.readings
    end

    private
      # A single source answering with these, keyed by name. The source is
      # asked for one tag and answers with everything it has, which is the
      # widest thing a real source could do and so the hardest case for the
      # placement to get right.
      def with_items(named)
        Projects.source(:things, name: "Things") do |_tag|
          named.map { |name, tags| item(name, tags) }
        end
      end

      def item(name, tags)
        { id: name.hash.abs, name: name, tags: tags, path: "/things/#{name}" }
      end
  end
end
