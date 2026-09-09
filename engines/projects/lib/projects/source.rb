module Projects
  # The seam, and the only thing this engine knows about the tools around it.
  #
  # A source is one tool's answer to one question: "what do you have carrying
  # this tag?" It is registered by the host, because only a host is allowed to
  # know about more than one tool at once, and what it answers with is plain
  # data — never a record, never an object of the tool's.
  #
  #   Projects.source :palettes, name: "Palettes", mark: "🐼" do |tag|
  #     Pandatone.palettes(tag: tag).map do |palette|
  #       { id: palette[:id], name: palette[:name], tags: palette[:tags],
  #         path: "/pandatone/palettes/#{palette[:id]}",
  #         swatches: Pandatone.palette_colors(palette[:id]).map { |color| color[:hex] } }
  #     end
  #   end
  #
  # A source that raises is a source that is down, not a page that is broken:
  # a project made of four tools should still show the three that answered.
  # What went wrong is carried on the source's own reading and said on the
  # page, because a silently short list is worse than one that explains itself.
  Source = Data.define(:key, :name, :mark, :reader) do
    def read(tag)
      Reading.new(source: self, items: build(tag), error: nil)
    rescue StandardError => e
      Reading.new(source: self, items: [], error: "#{e.class}: #{e.message}")
    end

    private
      def build(tag)
        Array(reader.call(tag)).map { |attributes| Item.from(self, attributes) }
      end
  end

  # One source's answer: what it had, or why it had nothing.
  Reading = Data.define(:source, :items, :error) do
    def down? = !error.nil?
  end
end
