module ApplicationHelper
  # Whether the request is inside a mounted engine. current_page? answers for
  # one address, and an engine is every address under its mount.
  def in_engine?(mount)
    request.path == mount.path || request.path.start_with?("#{mount.path}/")
  end
end
