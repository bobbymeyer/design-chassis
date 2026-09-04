# Chassis

A Rails app that mounts Rails engines together. Not a general use tool.

One server, one door, and the design tools it carries: each tool is a Rails
engine packaged as a gem, mounted at its own path, and the chassis is the
shell around them. It holds the server, the database, the account, the
[its-swiss](https://github.com/bobbymeyer/its-swiss) layout and the list of
what is mounted, and nothing else. `CLAUDE.md` is the architecture and the
rules; this file is how to run it.

## Running it

```sh
bin/setup                 # gems, database
bin/rails pandatone:seed  # a small, real palette library to look at
bin/rails server
bin/rails test:all        # unit, integration and system tests
bin/ci                    # what CI runs: style, audits, brakeman, tests
```

The first visit to an empty chassis makes the account. There is one, and the
door shuts behind it; a second is a console away if that day comes. Passwords
are eight characters at least and nothing else is asked of them. "Forgot your
password" needs mail — point `config.action_mailer.smtp_settings` at whatever
you run; until then, reset in `bin/rails console`.

The account page carries the API token every mounted tool's API takes, as
`Authorization: Bearer <token>`. Each tool describes its API at
`<tool>/api/v1/openapi`, which is the one thing not behind the token.

In development the its-swiss specimen is at `/its-swiss/specimen`.

## Where things are

| What | Where |
| --- | --- |
| The engine list | `lib/chassis/engines.rb` — the one place the chassis knows what it carries |
| The bay | `/` — what is mounted, and where |
| The tools | `/pandatone` — Pandatone, the palette library, from the `engine` branch of `bobbymeyer/pandatone` |
| The door | `app/controllers/{sessions,passwords,registrations}_controller.rb` for people, `api_controller.rb` for scripts, `accounts_controller.rb` for the token |
| The shell | `app/views/layouts/application.html.erb` fills its-swiss's slots: mark, nav, footer. An engine's layout renders it and adds its `:sections` to the nav |
| The theme | `app/assets/stylesheets/theme.css` and the typeface in the layout: Archivo, the accent, the warm greys, for every tool at once |
| The scale it is weighed on | `test/architecture/thin_chassis_test.rb` |

## Mounting an engine

One line, in `lib/chassis/engines.rb`:

```ruby
Mount.new(name: "Pandatone", path: "/pandatone", engine: "Pandatone::Engine")
```

The routes mount it, the masthead links to it, and the bay lists it. The
engine brings its own its-swiss dependency, its own stylesheets, its own
migrations and its own tests; the chassis adds a gem to the Gemfile, the line
above, a `bin/rails db:migrate`, and a test in `test/lib/chassis/engines_test.rb`
that asserts the mount.

What an engine gets from the chassis, and all it gets: a controller to
inherit from for its screens and one for its API, both of which decide who is
let in; a layout to render around its pages, with a `:sections` slot in the
nav; and a theme. Pandatone's README says the same from the other side.

A gem the chassis calls but does not serve — `Pandatone.palette(id)` from a
workflow, say — is bundled and not listed. The list is what has a page.

## What stays out

`test/architecture/thin_chassis_test.rb` fails the build if the chassis grows
a model that is not the account, a table that is not the account's, a query
outside the door, a reference to an engine's internals, or anything that
looks like colour arithmetic or SVG. A failure there is a capability that has
gone homeless. Move it into an engine; do not loosen the test.
