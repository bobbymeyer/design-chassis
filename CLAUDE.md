# Chassis — Claude Code Handoff

Host application for a family of small, composable design tools. Each tool is a Rails mountable engine packaged as a gem; the chassis mounts them and provides the shared shell. This document is the source of truth for what the chassis is, what it must never become, and the migration order.

## Where this repo is

Two engines are mounted, and they meet. Pandatone (`v0.1.0` of `bobbymeyer/pandatone`) is at `/pandatone`; Stripeclub (`bobbymeyer/stripeclub`) is at `/stripeclub`. Engines are gem-packaged, taken from a tag, not published to RubyGems. Each has an OpenAPI description and a public Ruby interface, and the chassis calls both through those alone. The one cross-tool workflow is `config/initializers/stripeclub.rb`: Stripeclub asks its host where palettes come from, and the chassis answers with `Pandatone.palettes` and `Pandatone.palette`. A method call and a map; Stripeclub never learns which Pandatone answered, and Pandatone never learns it was asked (`test/integration/stripeclub_test.rb`). See `README.md` for how to run it and where things live. The next engine is morgue.

- The engine list is `lib/chassis/engines.rb`. The routes mount what it lists; the nav and the bay link to it. Nothing else reads it. An engine's migrations run with the chassis's through the engine's own initializer; nothing is copied in.
- `test/architecture/thin_chassis_test.rb` is the scale the chassis is weighed on: only the auth models, only the auth tables plus the engines' own prefixed ones, no queries outside the auth files, no engine internals named anywhere, no color arithmetic or SVG. A failure there means a capability has gone homeless: move it into an engine, do not loosen the test.
- The door is the chassis's, for people and for scripts. `ApplicationController` authenticates a session; `ApiController` authenticates the account's API token, shown and regenerated on `/account`. An engine's controllers inherit from these two (`Pandatone.base_controller_class`, `Pandatone.api_base_controller_class`) and never learn what a user is.
- The shell is the chassis's. An engine's layout fills its-swiss's slots and renders `layouts/application` around them; the one slot the chassis offers engines is `:sections`, placed in the masthead nav after the engine list. Inside an engine's request the bare route helpers are the engine's, so everything the chassis renders or redirects to on its own routes goes through `main_app`.
- The theme is the chassis's: Archivo, the signal-red accent and the warm greys live in `theme.css` and the layout, so every tool is set in one voice. An engine ships components and a grid, never a typeface or an accent.
- Tools meet only in `config/initializers/`. An engine that consumes another declares a seam (`Stripeclub.palette_source`) that takes plain data in the other's wire format, defaults to HTTP, and never names the sibling; the chassis fills the seam with the sibling's public methods. That file is the whole of a workflow, and it is glue.

### What converting Pandatone taught

For the next engine, in the order the problems appeared:

1. `rails plugin new <name> --mountable` is the skeleton; merge the app into it, not the other way round. Wrap every Ruby file in `module <Name>`; give fixtures a `_fixture: model_class:` header so the accessors keep their names; qualify constants and partial paths in views, which have no lexical scope.
2. The engine's `ApplicationRecord` is `abstract_class`, never `primary_abstract_class`.
3. A gem's dependencies are resolved by Bundler and loaded by nobody: the engine requires propshaft, importmap, turbo, stimulus and its-swiss itself.
4. The dummy host under `test/` is the contract: the least a host must provide, and a place to prove the engine asks for nothing more.
5. The engine's JavaScript registers its own Stimulus controllers from a module the engine's layout imports; the host adds nothing to its importmap.
6. `git rm` a long list in one command and one missing path removes nothing, silently under `|| true`. Stripeclub shipped its old migrations into the chassis that way and made unprefixed tables there. Check `git ls-files` for what an application has and an engine does not before the first commit.
7. An engine that consumed a sibling over HTTP keeps its wire-format reader and its client, and gets a seam the host can fill: nothing in the engine names the sibling's Ruby.

## Context

Existing tools, all standalone Rails apps or gems today:

| Tool | What it is | Status |
| --- | --- | --- |
| **Pandatone** | Color palette library manager. Named/tagged colors, palettes queryable over REST. The keystone — everything else consumes it | Built and working. Ad hoc REST, no OpenAPI spec yet |
| **Stripeclub** | Stripe pattern generator consuming Pandatone palettes. Value-first design (grayscale slots), palettes applied as swappable colorways | Engine, mounted at `/stripeclub`; palettes from Pandatone in-process |
| **its-swiss** | Shared Swiss International Typographic Style gem: CSS standards + basic components (nav, footer, grid primitives — apps define their own grids) | 0.7.0 on RubyGems. Pandatone and the chassis consume it |
| **morgue** | Segmented, color-indexed reference archive (Pinterest-style) | Separate app, migrates later |

## Stack and conventions (non-negotiable)

- Rails 8, omakase. No deviations without asking.
- TDD. Tests written first, for everything.
- No Tailwind. Hand-written CSS via its-swiss. Swiss style: monochrome-first, values-first, color as small intentional accent.
- View Transitions between pages.
- Semantic parameter names everywhere (`hue_shift`, not `param1`).

## Architecture

### Three layers

1. **Core** — plain Ruby gem. The logic. No server. Testable in isolation.
2. **Interface** — the same gem renders, returning SVG/HTML directly. Output is visual and web-native, so the interface is the gem's return value.
3. **Host** — the chassis. One thin Rails app mounting the gems as engines. One deploy, one server bill.

### What the chassis contains

Server, DB connection, auth, shared its-swiss layout (outer shell: layout, nav, footer), and the list of mounted engines. **Nothing else.** No domain logic, ever.

### What an engine is

A Rails mountable engine (isolated namespace) packaged as a gem: own controllers, routes, views, migrations. Each engine declares its-swiss in its **own gemspec** — never rely on the chassis to provide it. Bundler resolves to one loaded copy.

Each engine is consumable three ways; the chassis chooses per consumer:

| Consumption mode | Mechanism | Gets |
| --- | --- | --- |
| Full app | `mount Pandatone::Engine, at: "/pandatone"` | Complete UI + API at that path |
| Library | Call `Pandatone.palette(id)`, don't mount | Logic only; caller renders its own UI |
| Component | Render an exposed partial/ViewComponent | Reusable UI fragment inside host pages |

### The one rule

**Tools call each other only through public interfaces. Never internals.**

- Alarm condition: `Pandatone::Palette.where(...)` appearing anywhere outside the Pandatone gem. The correct call is `Pandatone.palette(id)` — a public method with the same signature you'd wrap in HTTP later, so any tool can be split to its own deploy without touching anything else.
- Engines are ignorant of their siblings. Stripeclub does not know morgue exists.
- The chassis is the only component allowed to know about more than one tool.

### Chassis orchestrates, never reimplements

Cross-tool workflows live in the chassis. Every line of chassis workflow code must be engine-method-calls plus glue. A color calculation or SVG construction appearing in the chassis is a bug: that capability is homeless and belongs in an engine.

### Workflows

Do **not** build a general workflow engine. A workflow is a hardcoded ordered list of steps; each step declares its input and which engine method it calls; the chassis walks the list and pauses to render a form field where a human choice is needed. A fully automated run is the same machine with zero decision steps. Step inputs are fillable by human (form), LLM (prompt against the step's schema), or default/scheduler — three sources, one design. Extract a framework only after three real hardcoded workflows exist, never before.

## Migration order

1. ~~`rails new` the chassis: auth, its-swiss shell, empty engine list. Thin from day one.~~ **Done.**
2. ~~Extract **Pandatone** as a gem-packaged mountable engine (it's furthest along and everything consumes it).~~ **Done**: tagged `v0.1.0`, taken from the tag.
3. ~~Mount it in the chassis at `/pandatone`: one line in `lib/chassis/engines.rb`, and replace the test that asserts the list is empty with the first real mount.~~ **Done.**
4. ~~Retrofit an **OpenAPI spec** onto Pandatone during extraction — it's the reference implementation for the tools-self-describe principle. Spec on by default.~~ **Done**: `/pandatone/api/v1/openapi`, open to anyone, held to the routes by a test.
5. ~~Prove one consumer calling `Pandatone.palette(id)` through the public method only.~~ **Done**: `test/integration/pandatone_test.rb`.
6. ~~**Done when:** one vertical slice works end to end.~~ **Done.**
7. ~~Extract **Stripeclub**, mount it at `/stripeclub`, and hand it Pandatone's palettes in-process through a seam the chassis fills.~~ **Done.** Read-only tokens turned out unnecessary: Stripeclub calls `Pandatone.palette` and carries no token at all.
8. Next: **morgue**.

No big-bang rewrite. One engine at a time.

## Standing principles (govern all decisions)

- **Small doses of AI.** Any LLM integration is an optional parameter source, never load-bearing. The system must work with the model unplugged — a human, a random default, or a fixed config can always drive any node.
- **Tools self-describe.** OpenAPI spec on by default for every engine's API. It's part of definition-of-done, not a follow-up task.
- **Ecosystem citizenship.** Plain, portable REST first. n8n-wireable as a consequence, never contorted to fit any one ecosystem.
- **Keep the chassis thin.** It's the most powerful component and under constant gravitational pull to absorb "one more little thing." The health of the whole architecture is its emptiness.

## Anti-goals

- No general/configurable workflow engine.
- No custom node-canvas or graph platform.
- No engine reaching into another engine's models, tables, or internals.
- No domain logic in the chassis.
- No Tailwind, no CSS frameworks outside its-swiss.
