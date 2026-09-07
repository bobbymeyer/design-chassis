module Chassis
  # The list of mounted engines.
  #
  # This is the one place in the chassis allowed to know about more than one
  # tool, and the whole of what the chassis knows about any of them: a name
  # and a mark for the nav, a path to mount at, and the engine class. The routes mount
  # what is listed here; the bay and the masthead link to it. Nothing else
  # reads the list, because nothing else in the chassis should care which
  # tools are present.
  #
  # An engine is added by adding a line, in order of extraction. A gem that is
  # bundled but not listed is a library the chassis can call and not a page it
  # serves — which is a legitimate way to consume one.
  module Engines
    # The engine is named as a string because the constant exists only once
    # the gem is bundled, and a list of what to mount has to be readable
    # before anything is.
    # The mark is an emoji, the way the chassis's own is: one glyph a tool is
    # known by in the nav and on the bay, drawn in grey like the knobs.
    Mount = Data.define(:name, :mark, :path, :engine) do
      def constant = engine.constantize

      def at?(path) = path == self.path || path.start_with?("#{self.path}/")
    end

    ALL = [
      Mount.new(name: "Pandatone", mark: "🐼", path: "/pandatone", engine: "Pandatone::Engine"),
      Mount.new(name: "Stripeclub", mark: "🦓", path: "/stripeclub", engine: "Stripeclub::Engine"),
      Mount.new(name: "Badger", mark: "🦡", path: "/badger", engine: "Badger::Engine")
    ].freeze

    def self.all = ALL

    # The tool a path is inside, if it is inside one.
    def self.at(path) = ALL.find { |mount| mount.at?(path) }

    def self.empty? = ALL.empty?
  end
end
