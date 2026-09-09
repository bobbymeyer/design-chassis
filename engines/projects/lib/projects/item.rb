module Projects
  # One thing a tool has, as a project sees it: a name, the tags it carries,
  # somewhere to go and read it properly, and enough to draw it small.
  #
  # A value object rather than a Hash so that a view can ask it questions —
  # and so that a source handing over the wrong shape fails where it is
  # written rather than three templates later.
  #
  # The two ways to draw something small, and a source gives whichever it has:
  #
  # - swatches: a run of CSS colours, drawn as a strip. What a palette is.
  # - image: a URL the browser fetches, on the host's own door, so the cookie
  #   that opened this page opens it too. What a pattern is.
  #
  # Neither is required. A source with nothing to draw is a name and a link,
  # which is still the thing a project is for.
  Item = Data.define(:source, :id, :name, :tags, :path, :swatches, :image) do
    REQUIRED = %i[ id name path ].freeze

    def self.from(source, attributes)
      attributes = attributes.symbolize_keys
      missing = REQUIRED.reject { |key| attributes[key].present? }
      raise ArgumentError, "a #{source.key} item is missing #{missing.join(", ")}" if missing.any?

      new(
        source: source,
        id: attributes[:id],
        name: attributes[:name].to_s,
        tags: Array(attributes[:tags]).map { |tag| tag.to_s.downcase },
        path: attributes[:path].to_s,
        swatches: Array(attributes[:swatches]).map(&:to_s),
        image: attributes[:image].presence
      )
    end

    # Whether this carries every one of them. The whole placement rule is
    # this method: an item lands on the deepest project whose tags it all
    # carries, and one tag out of the line is not a near miss.
    def carries?(wanted)
      (Array(wanted).map(&:to_s) - tags).empty?
    end

    def drawable? = swatches.any? || image.present?
  end
end
