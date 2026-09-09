# Projects

Named projects that gather what the other tools have already tagged.

A project is a name and a tag. It holds nothing: what it shows is whatever
the tools around it answer when asked for that tag, so a palette joins a
project by being tagged in Pandatone and leaves it the same way. There is no
second list to keep in step.

Subprojects narrow. **An item lands on the deepest project whose tags it all
carries.** Under `bobbymeyer.com` (`#bobbymeyerdotcom`) with a subproject
`Summer 2026` (`#2026summer`):

| Tagged | Lands on |
| --- | --- |
| `#bobbymeyerdotcom` | bobbymeyer.com |
| `#bobbymeyerdotcom #2026summer` | Summer 2026, and not repeated at the top |
| `#2026summer` alone | nowhere — a subproject narrows a project, it does not stand beside one |

## Where it lives

In the chassis's repository, under `engines/projects`, taken as a path gem.
It is a whole mountable engine — its own namespace, its own `projects_`
tables, its own dummy host and suite — so extracting it is moving the
directory and changing one line of a Gemfile. It is here rather than in a
repository of its own because it has one host and nothing else consumes it
yet.

It could not be in the chassis proper: it needs a table, a model and views,
and the chassis's thinness guard refuses all three. That is the guard working.

## The seam

This engine knows about no tool in particular, and its gemspec depends on
none. What it gathers from is registered by the host, which is the one
component allowed to know about more than one tool at once:

```ruby
# config/initializers/projects.rb, in the host
Projects.source :palettes, name: "Palettes", mark: "🐼" do |tag|
  Pandatone.palettes(tag: tag).map do |palette|
    { id: palette[:id], name: palette[:name], tags: palette[:tags],
      path: "/pandatone/palettes/#{palette[:id]}",
      swatches: Pandatone.palette_colors(palette[:id]).map { |color| color[:hex] } }
  end
end
```

The block takes one tag and answers with plain hashes. Required: `id`,
`name`, `path`. Optional: `tags` (without them nothing can be placed),
and one of `swatches` (CSS colours, drawn as a strip) or `image` (a URL on
the host's own door, so the cookie that opened the page opens it too).

A source that raises is a source that is down, not a page that is broken: a
project of four tools shows the three that answered and says which one did
not.

## Mounting it

```ruby
# Gemfile
gem "projects", path: "engines/projects"

# config/routes.rb
mount Projects::Engine, at: "/projects"
```

Two things it takes from the host. The door — every screen inherits
`Projects.base_controller_class` and every API endpoint
`Projects.api_base_controller_class`, so the engine never learns what a user
is. The shell — the engine's layout fills its slots and renders the host's
`layouts/application` around them. The dummy application under `test/` is the
contract: the least a host has to provide, and a place to prove the engine
asks for nothing more.

## Calling it from Ruby

```ruby
Projects.projects                     # => [ { id:, name:, tag:, note:, parent:, depth: }, ... ]
Projects.project("bobbymeyerdotcom")  # => { ..., subprojects:, items:, unavailable: }
Projects.items("bobbymeyerdotcom")    # => [ { source:, id:, name:, tags:, path: }, ... ]
Projects.registered_sources           # => [ { key:, name:, mark: }, ... ]
```

The API's read endpoints call these same methods, so the two cannot drift.
The API describes itself at `/projects/api/v1/openapi`, and a test holds the
description to the routes in both directions.

## Running the suite

```bash
bin/rails db:migrate
bin/rails test
bin/rubocop
```
