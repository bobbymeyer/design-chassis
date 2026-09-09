# The wire format for a project. Key order here is the key order downstream
# tools see, and the contract test pins it, so treat this file as the
# interface.
module Projects
  module ProjectSerializer
    module_function

    # Collections carry the summary; only a project asked for by itself
    # carries what it gathers, because gathering asks every tool a question.
    def summary(project)
      {
        id: project.id,
        name: project.name,
        tag: project.tag,
        note: project.note,
        # The parent by its tag rather than its id: the tag is the address
        # everywhere else, and an id would be the one place it is not.
        parent: project.parent&.tag,
        depth: project.depth
      }
    end

    def one(project)
      summary(project).merge(
        subprojects: project.children.map(&:tag),
        items: project.items.map { |item| item(item) },
        # Named rather than silent: a client reading a short list should be
        # able to tell "nothing is filed here" from "one tool did not answer".
        unavailable: project.sources_down.map { |reading| { source: reading.source.key, error: reading.error } }
      )
    end

    def many(projects)
      projects.map { |project| summary(project) }
    end

    # What a project found. The path is where to read the thing properly, in
    # the tool that holds it — the whole point of gathering being a reference
    # and not a copy.
    def item(item)
      { source: item.source.key.to_s, id: item.id, name: item.name, tags: item.tags, path: item.path }
    end
  end
end
