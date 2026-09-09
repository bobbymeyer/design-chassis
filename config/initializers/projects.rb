# What a project gathers from.
#
# This is the chassis doing the one thing only the chassis may do: knowing
# about more than one tool at once. Projects depends on no tool and its
# gemspec names none — it asks whatever is registered here, and a chassis
# that registered nothing would have projects that are a name and a tag.
#
# Every line is an engine method call plus glue, which is the rule for
# orchestration in this application. Nothing here calculates anything: a hex
# is read off what Pandatone answered and handed on, an image is a URL on a
# path Stripeclub already serves. The moment a line of this file works out a
# colour or builds a picture, that capability has gone homeless and belongs
# in an engine.
#
# A source takes one tag and answers with plain hashes: id, name, tags, path,
# and one of swatches or image if there is something to draw with. Nothing
# that comes back is one of the answering tool's own objects, which is what
# makes each of these the same call you would wrap in HTTP the day that tool
# moves to its own deploy.
#
# Badger is not here. It is on its way to the archive, and its badges carry
# no tags to gather.
Rails.application.config.to_prepare do
  Projects.source :palettes, name: "Palettes", mark: "🐼" do |tag|
    Pandatone.palettes(tag: tag).map do |palette|
      {
        id: palette[:id],
        name: palette[:name],
        tags: palette[:tags],
        path: "/pandatone/palettes/#{palette[:id]}",
        # The palette as the strip it is. Asked for per palette because the
        # index carries no colours, and a project page shows a handful.
        swatches: Pandatone.palette_colors(palette[:id]).to_a.map { |color| color[:hex] }
      }
    end
  end

  Projects.source :colors, name: "Colours", mark: "🎨" do |tag|
    Pandatone.colors(tag: tag).map do |color|
      {
        id: color[:id],
        name: color[:name],
        tags: color[:tags],
        path: "/pandatone/colors/#{color[:id]}",
        swatches: [ color[:hex] ]
      }
    end
  end

  Projects.source :patterns, name: "Patterns", mark: "🦓" do |tag|
    Stripeclub.patterns(tag: tag).map do |pattern|
      {
        id: pattern[:id],
        name: pattern[:name],
        tags: pattern[:tags],
        path: "/stripeclub/patterns/#{pattern[:id]}",
        # The tile Stripeclub already serves, drawn in value. On the chassis's
        # own door, so the cookie that opened the project page fetches it.
        image: "/stripeclub/patterns/#{pattern[:id]}/tile.svg"
      }
    end
  end
end
