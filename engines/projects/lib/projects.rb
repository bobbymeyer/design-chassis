require "projects/version"
require "projects/engine"
# lib is not autoloaded, so what lives here is required by name. These two
# are required rather than autoloaded on purpose: a host registers its
# sources from an initializer, and autoloading a constant while the
# application is still initializing is not allowed.
require "projects/source"
require "projects/item"

# The public interface: what another tool may call, and the only thing it may
# call. Plain arguments in, plain data out — the same hashes the JSON API
# sends — so a caller never holds one of the engine's records.
#
#   Projects.projects                        # => [ { id:, name:, tag:, parent: }, ... ]
#   Projects.project("bobbymeyerdotcom")     # => { ..., subprojects:, items: }
#   Projects.items("bobbymeyerdotcom")       # => [ { source:, id:, name:, tags:, path: }, ... ]
#
# And the seam, which is what makes the rest of it work:
#
#   Projects.source :palettes, name: "Palettes", mark: "🐼" do |tag|
#     Pandatone.palettes(tag: tag).map { |palette| { id: ..., name: ..., tags: ..., path: ... } }
#   end
module Projects
  # The host's controllers the engine's inherit from. The host's decide who
  # gets in; the engine never has to know what a user is.
  mattr_accessor :base_controller_class, default: "::ApplicationController"
  mattr_accessor :api_base_controller_class, default: "::ApiController"

  # Where the things a project gathers come from. Empty by default, and an
  # empty list is a legitimate state — a chassis that mounts this and nothing
  # else has projects with nothing in them, which is a page that says so.
  mattr_accessor :sources, default: []

  class << self
    # Register a tool as somewhere to gather from. Called by the host, once
    # per tool, from an initializer.
    #
    # The block takes one tag and answers with an array of plain hashes:
    # id, name, tags, path, and either swatches or image if there is
    # something to draw. Registering the same key twice replaces it, so a
    # reloading host does not end up asking one tool four times.
    def source(key, name:, mark: nil, &reader)
      raise ArgumentError, "a source needs a block to read with" if reader.nil?

      sources.reject! { |source| source.key == key.to_sym }
      sources << Source.new(key: key.to_sym, name: name, mark: mark, reader: reader)
    end

    # For a host that rebuilds its list, and for a test that wants none.
    def sources_reset! = self.sources = []

    # Every project, roots first and each before its children, so a flat list
    # still reads as a tree.
    def projects
      ProjectSerializer.many(Project.in_tree_order)
    end

    # One project by tag or by id, with what it gathers, or nil.
    def project(key)
      project = Project.friendly(key)
      ProjectSerializer.one(project) if project
    end

    # What a project holds, without the project. The answer to "show me
    # everything filed under this", for a caller that has no interest in the
    # tree above it.
    def items(key)
      project = Project.friendly(key)
      return nil if project.nil?

      project.items.map { |item| ProjectSerializer.item(item) }
    end

    # Every source registered, so a client can name them the way the
    # interface does.
    def registered_sources
      sources.map { |source| { key: source.key, name: source.name, mark: source.mark } }
    end

    # The API's description of itself, as a Hash ready to serve as JSON.
    def openapi
      @openapi ||= YAML.safe_load_file(Engine.root.join("config/openapi.yml"))
    end
  end
end
