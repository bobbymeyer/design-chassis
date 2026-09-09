require "test_helper"

module Projects
  # The API describes itself, and the description has to be true. The routes
  # are what the API can answer; the spec is what it says it answers; this
  # holds the two to each other in both directions.
  class Api::V1::OpenapiTest < ActionDispatch::IntegrationTest
    test "serves the description as JSON, to anyone" do
      sign_out_client
      get api_v1_openapi_url

      assert_response :success
      assert_equal "application/json", response.media_type
      assert_equal "Projects", json.dig("info", "title")
    end

    test "every API route is in the spec, with its verb" do
      routed.each do |path, verb|
        assert spec.dig("paths", path, verb), "#{verb.upcase} #{path} is routed but not described"
      end
    end

    test "every operation in the spec is routed" do
      spec["paths"].each do |path, operations|
        operations.except("parameters").each_key do |verb|
          assert_includes routed, [ path, verb ], "#{verb.upcase} #{path} is described but not routed"
        end
      end
    end

    # The rule the whole engine turns on, written where a client generator
    # reads it. A consumer that does not know a subproject narrows will read
    # a top-level list as everything and be wrong.
    test "the placement rule is described, not left to be inferred" do
      assert_match(/deepest project whose tags it\s+all carries/, spec.dig("info", "description"))
    end

    private
      def spec
        @spec ||= Projects.openapi
      end

      def routed
        @routed ||= Projects::Engine.routes.routes.filter_map { |route|
          next unless route.defaults[:controller].to_s.start_with?("projects/api/v1/")

          path = route.path.spec.to_s.delete_suffix("(.:format)").delete_prefix("/api/v1")
          path = path.gsub(":id", "{key}") if route.defaults[:controller].end_with?("projects")
          path = path.gsub(/:(\w+)/, '{\1}')

          [ path, route.verb.downcase ]
        }.uniq.sort
      end
  end
end
