require "test_helper"

# The whole of v1, snapshotted. Every shape a consumer can receive is written
# out here longhand — the payloads and the error envelopes — so that a change
# to any of them fails in the one file whose job is to notice. Treat a failure
# here as a version bump rather than a fix.
#
# Behaviour lives in the controller tests beside this one. What this file pins
# is the wire format: keys, their order, and their types.
module Projects
  class Api::V1::ContractTest < ActionDispatch::IntegrationTest
    setup do
      @site = Project.create!(name: "bobbymeyer.com", tag: "bobbymeyerdotcom", note: "The site.")
      @summer = Project.create!(name: "Summer 2026", tag: "2026summer", parent: @site)

      source(:palettes, name: "Palettes", mark: "🐼") do |_tag|
        [ { id: 3, name: "Brand Core", tags: %w[ bobbymeyerdotcom brand ], path: "/pandatone/palettes/3",
            swatches: %w[ #E30613 #111111 ] } ]
      end
    end

    test "the projects index returns exactly this shape" do
      get api_v1_projects_url

      assert_response :success
      assert_equal "application/json", response.media_type

      assert_equal [
        { "id" => @site.id, "name" => "bobbymeyer.com", "tag" => "bobbymeyerdotcom",
          "note" => "The site.", "parent" => nil, "depth" => 0 },
        { "id" => @summer.id, "name" => "Summer 2026", "tag" => "2026summer",
          "note" => nil, "parent" => "bobbymeyerdotcom", "depth" => 1 }
      ], json
    end

    test "a project returns exactly this shape" do
      get api_v1_project_url(@site)

      assert_equal({
        "id" => @site.id, "name" => "bobbymeyer.com", "tag" => "bobbymeyerdotcom",
        "note" => "The site.", "parent" => nil, "depth" => 0,
        "subprojects" => [ "2026summer" ],
        "items" => [
          { "source" => "palettes", "id" => 3, "name" => "Brand Core",
            "tags" => [ "bobbymeyerdotcom", "brand" ], "path" => "/pandatone/palettes/3" }
        ],
        "unavailable" => []
      }, json)
    end

    # What is drawn with never leaves the engine: swatches and images are how
    # a page shows something small, not part of the contract a tool reads.
    test "an item's wire format carries where to read it, and nothing about drawing it" do
      get items_api_v1_project_url(@site)

      assert_equal [
        { "source" => "palettes", "id" => 3, "name" => "Brand Core",
          "tags" => [ "bobbymeyerdotcom", "brand" ], "path" => "/pandatone/palettes/3" }
      ], json
    end

    # A tool that did not answer is named. A client reading a short list has
    # to be able to tell "nothing is filed here" from "one tool is down".
    test "a source that did not answer returns exactly this shape" do
      Projects.sources_reset!
      source(:patterns, name: "Patterns") { |_tag| raise IOError, "nobody home" }

      get api_v1_project_url(@site)

      assert_equal [], json["items"]
      assert_equal [ { "source" => "patterns", "error" => "IOError: nobody home" } ], json["unavailable"]
    end

    test "a project is addressed by its tag or by its id" do
      get api_v1_project_url("bobbymeyerdotcom")
      by_tag = json

      get api_v1_project_url(@site.id)

      assert_equal by_tag, json
    end

    test "a tag nobody has returns exactly this error" do
      get api_v1_project_url("nothing-filed-here")

      assert_response :not_found
      assert_equal({ "error" => "Not found" }, json)
    end

    test "no token returns exactly this error" do
      sign_out_client
      get api_v1_projects_url, headers: { "Authorization" => "Bearer wrong" }

      assert_response :unauthorized
      assert_equal({ "error" => "Unauthorized" }, json)
    end
  end
end
