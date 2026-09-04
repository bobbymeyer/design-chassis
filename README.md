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
bin/setup           # gems, database
bin/rails server
bin/rails test:all  # unit, integration and system tests
bin/ci              # what CI runs: style, audits, brakeman, tests
```

The first visit to an empty chassis makes the account. There is one, and the
door shuts behind it; a second is a console away if that day comes. Passwords
are eight characters at least and nothing else is asked of them. "Forgot your
password" needs mail — point `config.action_mailer.smtp_settings` at whatever
you run; until then, reset in `bin/rails console`.

In development the its-swiss specimen is at `/its-swiss/specimen`.

## Where things are

| What | Where |
| --- | --- |
| The engine list | `lib/chassis/engines.rb` — the one place the chassis knows what it carries |
| The bay | `/` — what is mounted, and where. Empty until the first engine arrives |
| The door | `app/controllers/{sessions,passwords,registrations}_controller.rb`, from `bin/rails generate authentication` |
| The shell | `app/views/layouts/application.html.erb` fills its-swiss's slots: mark, nav, footer |
| The chassis's own CSS | `app/assets/stylesheets/theme.css`, and it should stay as short as it is |
| The scale it is weighed on | `test/architecture/thin_chassis_test.rb` |

## Mounting an engine

One line, in `lib/chassis/engines.rb`:

```ruby
Mount.new(name: "Pandatone", path: "/pandatone", engine: "Pandatone::Engine")
```

The routes mount it, the masthead links to it, and the bay lists it. The
engine brings its own its-swiss dependency, its own stylesheets, its own
migrations and its own tests; the chassis adds a gem to the Gemfile and the
line above. Then replace the test in `test/lib/chassis/engines_test.rb` that
asserts the list is empty with one that asserts the first mount.

A gem the chassis calls but does not serve — `Pandatone.palette(id)` from a
workflow, say — is bundled and not listed. The list is what has a page.

## What stays out

`test/architecture/thin_chassis_test.rb` fails the build if the chassis grows
a model that is not the account, a table that is not the account's, a query
outside the door, a reference to an engine's internals, or anything that
looks like colour arithmetic or SVG. A failure there is a capability that has
gone homeless. Move it into an engine; do not loosen the test.
