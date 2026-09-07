module ApplicationHelper
  # Whether the request is inside a mounted engine. current_page? answers for
  # one address, and an engine is every address under its mount.
  def in_engine?(mount)
    mount.at?(request.path)
  end

  # The tool the request is inside, if it is inside one.
  def current_mount
    Chassis::Engines.at(request.path)
  end

  # A tool's mark beside its name: the emoji in grey, hidden from a screen
  # reader because the name beside it already says which tool.
  def tool_mark(mount)
    tag.span(mount.mark, class: "glyph", aria: { hidden: true })
  end
end
