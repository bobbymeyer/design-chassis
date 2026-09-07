# Mockups

What a tool will look like before it is built, drawn at the width the tools
are laid out for. Each mockup is a directory with a generator and what it
reads; running the generator writes the design canvas's artboards to
`canvas/` and the bare boards to `boards/`, which `/gallery` frames as its
last row, beside the pages the tools serve. A drawing that drifts from the
tools it will join is drift too, and it shows there first.

| Mockup | What | Generator |
| --- | --- | --- |
| `badger-editor/` | The Badger editor: Compose, Dress and Start boards for Stockholm Stadion, under the chassis's masthead and Badger's subnav | `python3 build.py` in the directory; the fragments and tables beside it are what Badger rendered for the badge |
