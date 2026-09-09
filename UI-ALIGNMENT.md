# UI alignment across the tools

Three tools are set in one style, and by construction rather than by
copying: every one fills the slots of its-swiss's shell, reads its tokens,
uses its buttons, fields, flash and errors, and writes unlayered CSS that
wins over the library without out-specifying it. The chassis owns the voice
— Archivo, the signal-red accent, the warm greys — and no engine sets any of
it. That was true before this review and it is still true.

What had drifted was one level up: the patterns each engine grew on top of
the library. This file is the record of that review, what moved where, and
the rule that decides where a pattern lives. Stripeclub's
`ITS-SWISS-CANDIDATES.md` is the same instrument for the second consumer;
this is the third's, across all three.

## The rule

A pattern enters its-swiss after it appears in two applications, not before.
A pattern that is Pandatone's to know — anything that reads a palette —
enters Pandatone when a second consumer copies it. Everything else stays in
the engine that owns it, in that engine's own stylesheet, and says so at the
top of the file.

## What was found, and where it went

| Finding | Was | Now |
| --- | --- | --- |
| Three page heads: a 48px title with a lede and an actions row (Pandatone), a 32px h1 with inline buttons (Stripeclub, Badger), a bare header (the chassis) | Each engine's `components.css` | `page_head` in its-swiss 0.8. Every page of every tool opens with it; the engine copies are deleted |
| Three index idioms: filtered cards with live search (Pandatone), a table with previews (Stripeclub), cards without filters (Badger) | Pandatone's `shared/_index`, `_filter_row`, its live search controller | `search_form`, `filter_register`, `.cards` and `its-swiss-live-search` in its-swiss 0.8. All three indexes are filtered cards; Stripeclub and Badger narrow by name, by lean or by what is worn, and by order |
| The Stripeclub pattern, copied: catalogue, client, palette and colour readers, luminance, snapshot, colorway, rule, picker, strips, swatches, drift sentences | `Stripeclub::Pandatone::*`, `Badger::Pandatone::*`, two helpers each, two pickers | `Pandatone::Dresser` in Pandatone 0.2: value objects, three concerns for a consumer's own records, a controller concern, the picker and actions partials, three helpers, `pandatone/dresser.css`. Stripeclub keeps its two repeat-varying rule kinds; Badger keeps nothing of its own but the rank |
| Where palettes come from was the chassis's to say, twice | `Stripeclub.palette_source` and `Badger.palette_source` lambdas in two initializers | Nothing. With no `PANDATONE_URL` the dresser asks the Pandatone in the process through its public methods; the chassis no longer knows about two tools at once for this |
| Pandatone hand-wrote its fields and had no per-field errors | `form_with` and `.field` divs | `its_swiss_form_with` everywhere, the swatch entry row under its own `swatch` scope |
| The grid was layout-wide in Pandatone and per-view elsewhere, and Badger's forms fell off it | `content_for :main_class` in some views | Set once in each engine's layout |
| Only Pandatone shipped JavaScript the documented way | Stripeclub none; Badger declared and shipped nothing | Badger pins a module its layout imports and registers a controller from it; Stripeclub ships none and needs none. The host registers the library's two |
| Badger's stylesheet read `--rule-hairline`, no token at all | Every border fell through to its fallback | `--rule-hair` |
| Stripeclub carried a copy of the pagination partial and a numeric-cell correction | Both worked around bugs its-swiss 0.7 fixed | Deleted |
| Pandatone and Stripeclub both declared `--baseline` at 8px, the confusion the library's changelog says it removed | Two `tokens.css` | Pandatone's is `--swatch-step`; Stripeclub's measured nothing and is gone |
| Badger's rule column was `slot` for the rank and `index` for the palette position, against Stripeclub's `slot` for the position | Two vocabularies for one thing | `rank` and `slot`, in the table, the API and the dresser |
| Dead CSS: Stripeclub's footer and row-form rules | | Gone |
| Current-section computed by a helper in one engine and inline in two | | Still per engine; the library passes `current:` in on purpose, because only the engine knows its sections. Left as is |

## What stays in each tool, on purpose

- **Pandatone**: swatches, strips, the swatch row, the two card widths and the
  second density, the tags, the colour entry row. What a palette library
  measures.
- **Stripeclub**: the preview frame, the repeat and rows tables, the tiling
  status, the rough grid, the two repeat-varying rule kinds. What a stripe
  pattern lays out.
- **Badger**: the preview frame, the slots table with its bindings, the
  document, and from 0.4 the editor: the tree, the drawing with its
  construction as the controls, the inspector, the reference under it. What
  a badge lays out. The canvas is Badger's until a second tool wants one.

## A day of use

The second review, after a day inside the tools: what daily use asks of a
style is less talk and one red. Four rules, kept by its-swiss 0.9 and every
tool on it.

- **A working page does not scroll.** A page with several surfaces names
  them under its title — `page_head(sections:)` — and shows one at a time:
  the pattern page is Compose, Finish, Dress, Export; the badge page
  Compose, Dress, Export; the palette page Swatches, Export. The drawing
  and what is true of it stay in the left column and stay put. What is done
  daily is in the head, in the same position on every page, and each action
  returns to the surface it lives on.
- **Say each thing once.** The sentence over every table is behind one
  mark — `explain` — opened when it is asked for. A column that says the
  same thing four times is not information: a colorway lists only the slots
  bound to something other than their rank, and a repeat of equal stripes
  says so in a word and shows no width column.
- **One red per page.** The accent is for where you are on the site — the
  nav, the subnav, the page numbers — and for the one thing that cannot be
  undone. Where you are on a page, in a menu, in a filter is the weight, in
  ink.
- **One meaning per register.** A hint is prose and set at body size; a
  label is small, bold, on the line. The filter block is ruled once, below.

The gallery draws the twelve fields over every frame when asked, so a page
that fills half its measure shows as half. The editor is on the same fields:
three for the tree, six for the canvas, three for the inspector.

## Seeing it

`/gallery`, behind the door and not in production, frames the same screen of
every tool side by side — index, compose, dress — each the page the tool
already serves, at the width it is laid out for. Drift shows there first.
Its last row is the Badger editor as Badger 0.5 serves it: the start of a
badge, a composition on a shape; the Compose surface, the drawing with its
construction as the controls; the Dress surface. The editor was drawn before
it was built, as the boards in `mockups/badger-editor/`, and each board was
framed in this row until its page arrived and took its place; the boards
stay as the record of what was drawn.
The library's own specimen is at `/its-swiss/specimen` in development.

## The fourth tool

Projects arrived after this review and was built on its findings rather than
against them, so there is nothing here to correct. What it drew, and where
each thing was put:

- **The page head, the filter block, the cards, the form builder, the flash
  and the errors** are the library's, used as documented. The engine ships
  one stylesheet, unlayered, and adds no token at all — the accent, the
  typeface, the value scale, the field count and the baseline are the
  chassis's, and a project lays out nothing that needs a number of its own.
- **The tree** — a flat list indented by depth — is Projects's. A tree of
  four things does not need a tree control, and no second tool has one.
- **A thing from another tool, drawn small** is Projects's, and is the one
  shape here nothing else has: a square figure carrying either a strip of
  CSS colours or an image the tool already serves, at one field wide, six to
  a row. It is a contact sheet, not a reading of any one piece.
- **The subnav's `:sections` slot is left empty.** The chassis's subnav
  already carries the tool's mark and its name, and this tool has one
  destination — a link reading "Projects" under a mark reading "Projects" is
  the same word twice. A tool fills that slot when it has surfaces to name.

Two things it did to its siblings:

- **Stripeclub's patterns grew tags**, because a project gathers by tag and
  had nothing to gather. `Stripeclub::Taggable` is a copy of Pandatone's
  concern, not an include of it: `Pandatone::Dresser` is published surface
  because a consumer asks Pandatone for palettes, and nothing about a
  pattern's tags asks Pandatone anything. If a third tool draws it, the home
  is a small gem of its own — not the host, which holds no models, and not
  its-swiss, which is a typographic style and not a place to keep SQL.
- **`tag_links` and the `.tags` line are now at two applications**, so they
  are a candidate for its-swiss under the rule above. Recorded as entry 8 in
  Stripeclub's `ITS-SWISS-CANDIDATES.md`.

And one thing this document had already said, which was written again
anyway: **Badger read `--rule-hairline`, a token that does not exist, and
every border fell through to its fallback.** The tags on a Stripeclub card
were written asking for `--ink-2`, which does not exist either, and were set
at the weight of a name until the page was looked at. The lesson is not in
the table above until it is read before the CSS is written: the library's
quiet ink is `--ink-quiet` and its shaded paper is `--paper-shaded`, and
`its_swiss/tokens.css` is the list.

## What is left

- its-swiss 0.8.0, Pandatone 0.2.0, Stripeclub 0.2.0 and Badger 0.2.0 are
  on branches. Each Gemfile pins the branch until the tag exists; the pins
  go back to versions and tags then, in this order: its-swiss (RubyGems),
  Pandatone, then Stripeclub and Badger, then the chassis.
- The dresser has no editor for rules beyond assigning a slot. Stripeclub
  displays four kinds and lets none be chosen; that is the next thing the
  dresser should carry, once.
