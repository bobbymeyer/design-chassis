# The gallery: the same screen of every tool, side by side, so that the tools
# drifting apart shows up on a page rather than in a survey.
#
# Each frame is a page the tool already serves — nothing is rendered here
# that the tool does not render itself — and the one thing the chassis adds is
# which page of each tool stands for which screen. That is the chassis doing
# the one thing only the chassis may do: knowing about more than one tool at
# once. What it reads of each is its public Ruby methods, to find something
# to open, and nothing else.
#
# The last row is the Badger editor: the start of a badge, the Compose
# surface and the Dress surface, each the page Badger serves. The editor
# was drawn before it was built, as boards in mockups/badger-editor/, and
# each board left this row as its page arrived; the boards stay in the
# repository as the record of what was drawn.
class GalleryController < ApplicationController
  Screen = Data.define(:name, :note, :frames)
  Frame = Data.define(:name, :path, :home)

  def show
    @screens = [
      screen("Index", "The page head, the filter block and the cards are the library's.",
        "/pandatone/palettes", "/stripeclub/patterns", "/badger/badges"),
      screen("Compose", "Every form is the library's builder: a label, a control, a hint, the refusal.",
        "/pandatone/palettes/new", "/stripeclub/patterns/new", "/badger/badges/new"),
      screen("Dress", "The picker is Pandatone's dresser's, on every tool that wears a palette; Pandatone shows the palette itself.",
        first_palette_path, first_dress_path("/stripeclub/patterns", Stripeclub.patterns),
        first_dress_path("/badger/badges", Badger.badges)),
      Screen.new(name: "Editor",
        note: "The Badger editor: a badge started from a composition on a shape, composed as a drawing with its construction as the controls, and dressed.",
        frames: [
          Frame.new(name: "Start", path: "/badger/badges/new", home: "/badger"),
          Frame.new(name: "Compose", path: first_badge_path, home: "/badger"),
          Frame.new(name: "Dress", path: first_badge_path && "#{first_badge_path}?section=dress", home: "/badger")
        ])
    ]
  end

  private
    # One frame per tool, in the order the tools are mounted.
    def screen(name, note, *paths)
      frames = Chassis::Engines.all.zip(paths).map { |mount, path| Frame.new(name: mount.name, path: path, home: mount.path) }
      Screen.new(name: name, note: note, frames: frames)
    end

    def first_palette_path
      first = Pandatone.palettes.first
      first ? "/pandatone/palettes/#{first[:id]}" : nil
    end

    def first_badge_path
      @first_badge_path ||= (first = Badger.badges.first) && "/badger/badges/#{first[:id]}"
    end

    def first_dress_path(prefix, summaries)
      first = summaries.first
      first ? "#{prefix}/#{first[:id]}/colorways/new" : nil
    end
end
