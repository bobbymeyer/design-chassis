# The gallery: the same screen of every tool, side by side, so that the tools
# drifting apart shows up on a page rather than in a survey.
#
# Each frame is a page the tool already serves — nothing is rendered here
# that the tool does not render itself — and the one thing the chassis adds is
# which page of each tool stands for which screen. That is the chassis doing
# the one thing only the chassis may do: knowing about more than one tool at
# once. What it reads of each is its public Ruby methods, to find something
# to open, and nothing else.
class GalleryController < ApplicationController
  Screen = Data.define(:name, :note, :paths)

  def show
    @mounts = Chassis::Engines.all
    @screens = [
      Screen.new(name: "Index", note: "The page head, the filter block and the cards are the library's.",
        paths: [ "/pandatone/palettes", "/stripeclub/patterns", "/badger/badges" ]),
      Screen.new(name: "Compose", note: "Every form is the library's builder: a label, a control, a hint, the refusal.",
        paths: [ "/pandatone/palettes/new", "/stripeclub/patterns/new", "/badger/badges/new" ]),
      Screen.new(name: "Dress", note: "The picker is Pandatone's dresser's, on every tool that wears a palette; Pandatone shows the palette itself.",
        paths: [ first_palette_path, first_dress_path("/stripeclub/patterns", Stripeclub.patterns),
                 first_dress_path("/badger/badges", Badger.badges) ])
    ]
  end

  private
    def first_palette_path
      first = Pandatone.palettes.first
      first ? "/pandatone/palettes/#{first[:id]}" : nil
    end

    def first_dress_path(prefix, summaries)
      first = summaries.first
      first ? "#{prefix}/#{first[:id]}/colorways/new" : nil
    end
end
