module Chassis
  # The list of mounted engines.
  #
  # This is the one place in the chassis allowed to know about more than one
  # tool, and the whole of what the chassis knows about any of them: a name
  # for the nav, a path to mount at, and the engine class. The routes mount
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
    Mount = Data.define(:name, :path, :engine) do
      def constant = engine.constantize
    end

    ALL = [
      Mount.new(name: "Pandatone", path: "/pandatone", engine: "Pandatone::Engine")
    ].freeze

    def self.all = ALL

    def self.empty? = ALL.empty?
  end
end
