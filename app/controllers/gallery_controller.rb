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
# The last row is the one exception: the Badger editor as drawn, before it is
# built. Its boards are the design's, not a tool's, and they are framed here
# so the drawing is weighed on the same page as the pages — a mockup that
# drifts from the tools it will join is drift too.
class GalleryController < ApplicationController
  Screen = Data.define(:name, :note, :frames)
  Frame = Data.define(:name, :path, :home)

  MOCKUP = Rails.root.join("mockups/badger-editor")
  BOARDS = %w[ compose dress start ].freeze

  def show
    @screens = [
      screen("Index", "The page head, the filter block and the cards are the library's.",
        "/pandatone/palettes", "/stripeclub/patterns", "/badger/badges"),
      screen("Compose", "Every form is the library's builder: a label, a control, a hint, the refusal.",
        "/pandatone/palettes/new", "/stripeclub/patterns/new", "/badger/badges/new"),
      screen("Dress", "The picker is Pandatone's dresser's, on every tool that wears a palette; Pandatone shows the palette itself.",
        first_palette_path, first_dress_path("/stripeclub/patterns", Stripeclub.patterns),
        first_dress_path("/badger/badges", Badger.badges)),
      Screen.new(name: "Editor, as drawn",
        note: "The Badger editor's mockup, under the chassis's masthead and Badger's subnav: what the tool will look like from the inside once it is built.",
        frames: BOARDS.map { |board| Frame.new(name: board.capitalize, path: "/gallery/badger-editor/#{board}", home: "/badger") })
    ]
  end

  # One board of the mockup, bare: the drawing inside a page that declares the
  # typeface and nothing else, so the frame shows the board and not a shell
  # around a shell.
  def board
    raise ActionController::RoutingError, "No such board" unless BOARDS.include?(params[:board])

    render html: MOCKUP.join("boards/#{params[:board]}.html").read.html_safe, layout: "board" # rubocop:disable Rails/OutputSafety -- the mockup's own HTML, from the repository
  end

  # The reference photograph the Dress board wears at half strength.
  def reference
    send_file MOCKUP.join("stockholm.jpg"), type: "image/jpeg", disposition: "inline"
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

    def first_dress_path(prefix, summaries)
      first = summaries.first
      first ? "#{prefix}/#{first[:id]}/colorways/new" : nil
    end
end
