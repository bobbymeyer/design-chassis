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
  document. What a badge lays out. The editor canvas that is mocked in the
  Badger Editor design is Badger's until a second tool wants a canvas.

## Seeing it

`/gallery`, behind the door and not in production, frames the same screen of
every tool side by side — index, compose, dress — each the page the tool
already serves, at the width it is laid out for. Drift shows there first.
The library's own specimen is at `/its-swiss/specimen` in development.

## What is left

- its-swiss 0.8.0, Pandatone 0.2.0, Stripeclub 0.2.0 and Badger 0.2.0 are
  on branches. Each Gemfile pins the branch until the tag exists; the pins
  go back to versions and tags then, in this order: its-swiss (RubyGems),
  Pandatone, then Stripeclub and Badger, then the chassis.
- The dresser has no editor for rules beyond assigning a slot. Stripeclub
  displays four kinds and lets none be chosen; that is the next thing the
  dresser should carry, once.
