# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [ File.expand_path("../test/dummy/db/migrate", __dir__) ]
ActiveRecord::Migrator.migrations_paths << File.expand_path("../db/migrate", __dir__)
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    # Every test starts with no sources at all, because the sources are the
    # host's and a test that inherited another test's would be reading a
    # tool that is not there. A test that wants one registers it.
    setup { Projects.sources_reset! }
    teardown { Projects.sources_reset! }

    # One source, answering with these. A source is a name and a lambda, so a
    # fake one is not a stand-in for the real thing — it is the same thing,
    # which is the point of the seam.
    def source(key = :things, name: "Things", mark: nil, &items)
      Projects.source(key, name: name, mark: mark, &items)
    end

    # An item in the shape a source hands over: plain data, and never one of
    # the answering tool's own objects.
    def item(name, tags, **overrides)
      { id: name.hash.abs, name: name, tags: tags, path: "/things/#{name}" }.merge(overrides)
    end
  end
end

class ActionDispatch::IntegrationTest
  # The engine's routes, by their own names. The dummy application mounts the
  # engine at /projects, and these helpers already know that.
  include Projects::Engine.routes.url_helpers

  # The door is the host's. The dummy host under test/ opens its screens to a
  # cookie and its API to one token, and every test starts through both:
  # Projects has nothing to say about who gets in. The one test that is about
  # the door signs out first.
  setup do
    sign_in_as
    sign_in_client
  end

  def sign_in_as(_user = nil)
    cookies[:signed_in] = "yes"
  end

  # Written blank rather than deleted: in an integration session the jar is
  # what the next request sends, and `delete` schedules a removal in a
  # response the test never makes. The dummy's door reads the value, so a
  # blank one is shut.
  def sign_out
    cookies[:signed_in] = ""
  end

  def sign_in_client(_user = nil)
    @api_token = Dummy::API_TOKEN
  end

  def sign_out_client
    @api_token = nil
  end

  def json
    JSON.parse(response.body)
  end

  %w[ get post patch put delete ].each do |verb|
    define_method(verb) do |path, **options|
      if @api_token
        options[:headers] = { "Authorization" => "Bearer #{@api_token}" }.merge(options[:headers] || {})
      end

      super(path, **options)
    end
  end
end
