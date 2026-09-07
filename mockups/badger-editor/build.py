# The Badger Editor, as drawn: three boards of the design canvas at
# 1440 × 900, built from the badge's own geometry (the fragments and tables
# beside this script are what Badger rendered for Stockholm Stadion). Run it
# here: it writes the canvas artboards to canvas/ for reseeding the design
# artifact, and the bare boards to boards/ for the chassis's gallery, which
# frames them beside the pages the tools serve.
import json, os
os.makedirs("canvas", exist_ok=True); os.makedirs("boards", exist_ok=True)

def write(name, html):
    """The canvas gets the whole artboard; the gallery gets the board alone —
    what stands between the helmet and the foot, with a rule for links, and
    with the reference picture fetched from where the chassis serves it."""
    open(f"canvas/{name}.dc.html", "w").write(html)
    body = html[html.index("</helmet>") + len("</helmet>"):html.index(FOOT)].strip()
    body = body.replace('src="stockholm.jpg"', 'src="/gallery/badger-editor/stockholm.jpg"')
    open(f"boards/{name.lower()}.html", "w").write(
        f'<style>a {{ color: {QUIET}; }} a:hover {{ color: {INK}; }}</style>\n{body}\n')
badge = open("badge.svg.fragment").read().strip()
dressed = open("badge-dressed.svg.fragment").read().strip()
cons = dict(l.split("\t") for l in open("construction.tsv").read().splitlines())
pts = {k: (float(x), float(y)) for k, x, y in (l.split("\t") for l in open("points.tsv").read().splitlines())}
placements = [tuple(map(float, l.split("\t"))) for l in open("placements.tsv").read().splitlines()]

HEAD = '''<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <script src="./support.js"></script>
</head>
<body>
<x-dc>
<helmet>
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Archivo:wght@400;500;700&display=swap">
  <style>
    body { margin: 0; }
    a { color: oklch(54% 0.006 95); } a:hover { color: oklch(18% 0.006 95); }
  </style>
</helmet>'''
FOOT = '''</x-dc>
</body>
</html>'''
PAPER = "oklch(98% 0.006 95)"; SHADED = "oklch(94% 0.006 95)"; RULE = "oklch(89% 0.006 95)"; RULE_STRONG = "oklch(72% 0.006 95)"
QUIET = "oklch(54% 0.006 95)"; INK = "oklch(18% 0.006 95)"; ACCENT = "#e30613"
FONT = "font-family: 'Archivo', 'Helvetica Neue', Helvetica, Arial, sans-serif;"
COL, GUT = (1312 - 48 - 11 * 24) / 12.0, 24
FIELDS = lambda n: n * COL + (n - 1) * GUT
W, H = int(round(FIELDS(6))), 528
K = H / 600.0

def masthead(section="Badges"):
    """The chassis masthead as merged: the wordmark, a Tools menu (closed, and
    marked current because a tool is where we are), Account on the right, no
    sign out. Under it the tool's subnav: a shaded band three lines tall with
    the tool's mark and its sections, the current one in the accent."""
    def link(name, cur=False, bold=False, color=None):
        aria = ' aria-current="page"' if cur else ''
        return f'<a href="#"{aria} style="text-decoration: none; color: {color or (ACCENT if cur else QUIET)}; font-weight: {700 if (cur or bold) else 400}; font-size: 16px; line-height: 24px;">{name}</a>'
    glyph = lambda e: f'<span aria-hidden="true" style="margin-right: 8px;">{e}</span>'
    return f'''<header style="display: flex; align-items: flex-end; gap: 24px 32px; padding: 24px 24px 23px; border-bottom: 1px solid {RULE}; max-width: 1312px; margin: 0 auto; box-sizing: border-box;">
  <p style="margin: 0; font-weight: 700; letter-spacing: -0.015em; white-space: nowrap; font-size: 16px; line-height: 24px;">{glyph("🎛️")}<a href="#" style="text-decoration: none; color: {INK};">Chassis</a></p>
  <nav style="display: flex; flex: 1; align-items: flex-end; gap: 24px;">
    <details style="position: relative;"><summary style="list-style: none; cursor: pointer; white-space: nowrap; color: {INK}; font-weight: 700; font-size: 16px; line-height: 24px;">{glyph("🧰")}Tools<span style="color: {QUIET}; font-weight: 400;"> ▾</span></summary></details>
    <span style="flex: 1;"></span>
    {link("Account")}
  </nav>
</header>
<nav style="background: {SHADED}; box-shadow: inset 0 -1px 0 {RULE};">
  <div style="display: flex; align-items: flex-end; gap: 24px 32px; padding: 24px; max-width: 1312px; margin: 0 auto; box-sizing: border-box;">
    <a href="#" style="text-decoration: none; color: {QUIET}; font-weight: 700; font-size: 16px; line-height: 24px;">{glyph("🦡")}Badger</a>
    {link(section, cur=True)}
  </div>
</nav>'''

def icon(d, size=16, stroke=INK):
    return f'<svg width="{size}" height="{size}" viewBox="0 0 16 16" fill="none" stroke="{stroke}" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="display: block;">{d}</svg>'
EYE = '<path d="M1.5 8s2.5-4.5 6.5-4.5S14.5 8 14.5 8 12 12.5 8 12.5 1.5 8 1.5 8z"/><circle cx="8" cy="8" r="2"/>'
PLUS = '<path d="M8 3v10M3 8h10"/>'
CHEV = '<path d="M6 4l4 4-4 4"/>'

def button(label, primary=False, quiet=False):
    if primary: box = f"background: {INK}; color: {PAPER};"
    elif quiet: box = f"background: transparent; color: {INK};"
    else: box = f"background: transparent; color: {INK}; box-shadow: inset 0 0 0 1px {RULE};"
    return f'<button style="{FONT} font-size: 16px; line-height: 24px; border: 0; padding: 12px 16px; cursor: pointer; white-space: nowrap; {box}">{label}</button>'

def segmented(options, active):
    parts = []
    for o in options:
        on = o == active
        parts.append(f'<button style="{FONT} font-size: 12px; line-height: 24px; border: 0; padding: 0 12px; cursor: pointer; background: {INK if on else "transparent"}; color: {PAPER if on else INK}; box-shadow: inset 0 0 0 1px {INK if on else RULE};">{o}</button>')
    return f'<div style="display: flex; gap: 0;">{"".join(parts)}</div>'

def field(label, control, hint=None, error=None):
    h = f'<p style="margin: 0; font-size: 16px; line-height: 24px; color: {QUIET};">{hint}</p>' if hint else ''
    e = f'<p style="margin: 0; font-size: 16px; line-height: 24px; color: {ACCENT};">{error}</p>' if error else ''
    return f'''<div style="display: flex; flex-direction: column; gap: 0; width: 100%;">
      <label style="font-size: 12px; line-height: 24px; font-weight: 700; color: {QUIET};">{label}</label>
      {control}{h}{e}
    </div>'''

def text_control(value, unit=None):
    u = f'<span style="color: {QUIET}; font-size: 12px; margin-left: 8px;">{unit}</span>' if unit else ''
    return f'<div style="display: flex; align-items: baseline; border-bottom: 1px solid {INK}; padding: 0 0 5px; font-size: 16px; line-height: 24px;"><span style="flex: 1;">{value}</span>{u}</div>'

def pair_control(value, note):
    return f'<div style="display: flex; align-items: baseline; justify-content: space-between; border-bottom: 1px solid {INK}; padding-bottom: 5px;"><span style="font-size: 16px; line-height: 24px;">{value}</span><span style="font-size: 12px; color: {QUIET};">{note}</span></div>'

def slider(value, frac, unit=""):
    return f'''<div style="display: flex; align-items: center; gap: 12px;">
      <div style="flex: 1; position: relative; height: 24px;">
        <div style="position: absolute; left: 0; right: 0; top: 11px; height: 1px; background: {RULE_STRONG};"></div>
        <div style="position: absolute; left: 0; width: {frac*100:.0f}%; top: 11px; height: 1px; background: {INK};"></div>
        <div style="position: absolute; left: calc({frac*100:.0f}% - 6px); top: 6px; width: 12px; height: 12px; background: {PAPER}; box-shadow: inset 0 0 0 1.5px {INK};"></div>
      </div>
      <span style="font-size: 16px; line-height: 24px; min-width: 64px; text-align: right; font-variant-numeric: tabular-nums;">{value}{unit}</span>
    </div>'''

def tree(selected="STOCKHOLM"):
    def row(label, meta, depth=0, sel=False, chev=None, invisible=False):
        eye = icon(EYE, 12, RULE_STRONG if invisible else QUIET)
        ch = icon(CHEV, 12, QUIET) if chev else '<span style="width: 12px;"></span>'
        return f'''<div style="display: flex; align-items: center; gap: 8px; padding: 0 8px 0 {8 + depth*16}px; height: 24px; {f"background: {SHADED}; box-shadow: inset 2px 0 0 {ACCENT};" if sel else ""}">
        {ch}<span style="flex: 1; font-size: 12px; line-height: 24px; color: {ACCENT if sel else INK}; font-weight: {700 if sel else 400}; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">{label} <span style="color: {QUIET}; font-weight: 400;">{meta}</span></span>{eye}</div>'''
    rows = [
        row("Stockholm Stadion", "superellipse", 0, chev=True, invisible=True),
        row("ring", "band 153 · ground", 1),
        row("STOCKHOLM", "ring · top", 1, sel=(selected=="STOCKHOLM")),
        row("STADION", "ring · bottom", 1),
        row("setting line", "rectangle", 1, chev=True, invisible=True),
        row("19", "fit box · h 119", 2),
        row("12", "fit box · h 119", 2),
    ]
    adds = "".join(f'<button style="{FONT} font-size: 12px; line-height: 24px; border: 0; background: transparent; color: {QUIET}; padding: 0; cursor: pointer; display: flex; align-items: center; gap: 4px;">{icon(PLUS, 12, QUIET)}{l}</button>' for l in ["Region", "Type", "Child", "Artwork"])
    return f'''<aside style="width: {FIELDS(3):.0f}px; flex: none; display: flex; flex-direction: column; gap: 0;">
    <h3 style="margin: 0; font-size: 16px; line-height: 24px; font-weight: 700;">Document</h3>
    <p style="margin: 0 0 24px; font-size: 16px; line-height: 24px; color: {QUIET};">A tree of containers. Select a line to work on it.</p>
    <div style="display: flex; flex-direction: column; gap: 0; border-top: 1px solid {RULE}; border-bottom: 1px solid {RULE}; padding: 12px 0;">{"".join(rows)}</div>
    <div style="display: flex; flex-direction: column; gap: 0; padding: 12px 8px;">{adds}</div>
    <div style="flex: 1;"></div>
    <div style="border-top: 1px solid {RULE}; padding-top: 11px;">
      <p style="margin: 0; font-size: 12px; line-height: 24px; color: {QUIET};">The document <a href="#" style="color: {QUIET};">as YAML</a> · <a href="#" style="color: {QUIET};">as JSON</a></p>
      <p style="margin: 0; font-size: 12px; line-height: 24px; color: {QUIET};">Version 7 · saved 2 min ago</p>
    </div>
  </aside>'''

def canvas(mode="compose", construction=True, reference=False):
    overlay = ""
    if construction:
        hair = f'stroke="{RULE_STRONG}" stroke-width="1" fill="none"'
        dash = f'stroke="{RULE_STRONG}" stroke-width="1" fill="none" stroke-dasharray="4 4"'
        sel = f'stroke="{ACCENT}" stroke-width="1.5" fill="none"'
        ts, te = pts["top_start"], pts["top_end"]
        n19, n12 = pts["19"], pts["12"]
        handle = lambda x, y: f'<circle cx="{x}" cy="{y}" r="6" fill="{PAPER}" stroke="{ACCENT}" stroke-width="1.5"/>'
        label = lambda x, y, t, col=QUIET, anchor="start": f'<text x="{x}" y="{y}" font-size="11" fill="{col}" text-anchor="{anchor}" style="{FONT}">{t}</text>'
        cross = lambda x, y: f'<path d="M{x-7} {y}H{x+7}M{x} {y-7}V{y+7}" stroke="{RULE_STRONG}" stroke-width="1"/>'
        glyph_marks = "".join(f'<circle cx="{x}" cy="{y}" r="2" fill="{ACCENT}"/>' for x, y, _ in placements)
        # the S|T junction, projected out to the outline and pushed 12px clear of it
        jx, jy, _ = placements[1]
        t = 1.493
        pin = (jx*t - 0.698*12, jy*t - 0.716*12)
        overlay = f'''
        <path d="{cons['outline']}" {hair}/>
        <path d="{cons['inner']}" {hair}/>
        <path d="{cons['bottom_baseline']}" {dash}/>
        <path d="M-320 0H320" {dash}/>
        <path d="{cons['top_baseline']}" {sel}/>
        {glyph_marks}
        {handle(ts[0], ts[1])}{handle(te[0], te[1])}
        {label(ts[0]-14, ts[1]+4, "from 202°", ACCENT, "end")}{label(te[0]+14, te[1]+4, "to 338°", ACCENT)}
        {cross(n19[0], n19[1])}{cross(n12[0], n12[1])}
        {label(-300, -6, "setting line")}
        <g transform="translate({pin[0]-7} {pin[1]-7})"><circle cx="7" cy="7" r="7" fill="{ACCENT}"/><path d="M7 3.5v4M7 9.5v.5" stroke="{PAPER}" stroke-width="1.5" stroke-linecap="round"/></g>
        {label(pin[0]-14, pin[1]-3, "tracking −47", ACCENT, "end")}{label(pin[0]-14, pin[1]+11, "letters collide", ACCENT, "end")}'''
    body = dressed if mode == "dress" else badge
    art = f'<g opacity="{0.68 if reference else 1}">{body}</g>'
    ref = ''
    if reference:
        s = 560/952 * K
        iw, ih = 888*s, 1083*s
        ref = f'<img src="stockholm.jpg" style="position: absolute; left: {W/2 - 451*s:.1f}px; top: {H/2 - 528*s:.1f}px; width: {iw:.1f}px; height: {ih:.1f}px; opacity: 0.5;">'
    tools = [("Construction", construction), ("Reference", reference), ("Grid", False)]
    chips = "".join(f'<button style="{FONT} font-size: 12px; line-height: 24px; border: 0; padding: 0 12px; cursor: pointer; background: {SHADED if on else "transparent"}; color: {INK}; box-shadow: inset 0 0 0 1px {INK if on else RULE}; display: flex; align-items: center; gap: 6px;"><span style="width: 6px; height: 6px; background: {ACCENT if on else RULE_STRONG};"></span>{t}</button>' for t, on in tools)
    return f'''<div style="width: {W}px; flex: none; display: flex; flex-direction: column; gap: 0;">
    <div style="position: relative; width: {W}px; height: {H}px; background: {SHADED}; box-shadow: inset 0 0 0 1px {RULE}; overflow: hidden;">
      {ref}
      <svg viewBox="{-W/2/K:.1f} -300 {W/K:.1f} 600" width="{W}" height="{H}" style="position: absolute; left: 0; top: 0; display: block;">
        {art}
        {overlay}
      </svg>
    </div>
    <div style="display: flex; align-items: center; gap: 8px; padding: 12px 0 0;">
      {chips}
      <span style="flex: 1;"></span>
      <span style="font-size: 12px; line-height: 24px; color: {QUIET}; font-variant-numeric: tabular-nums;">782 × 952 units at 59%</span>
      <span style="width: 8px;"></span>
      {segmented(["Fit", "100%", "200%"], "Fit")}
    </div>
  </div>'''

def swatch(hexv):
    return f'<span style="display: inline-block; width: 12px; height: 12px; background: {hexv}; box-shadow: inset 0 0 0 1px {RULE}; vertical-align: -1px; margin-right: 6px;"></span>'

def inspector_compose():
    link = lambda t: f'<a href="#" style="font-size: 12px; line-height: 24px; color: {QUIET};">{t}</a>'
    return f'''<aside style="width: {FIELDS(3):.0f}px; flex: none; min-width: 0; display: flex; flex-direction: column; gap: 4px;">
    <div>
      <p style="margin: 0; font-size: 12px; line-height: 24px; color: {QUIET}; font-weight: 700;">Type · follows the ring</p>
      <h3 style="margin: 0; font-size: 24px; line-height: 32px; font-weight: 700; letter-spacing: -0.015em;">STOCKHOLM</h3>
    </div>
    {field("Text", text_control("STOCKHOLM"))}
    {field("Font", pair_control("DejaVu Sans", "Regular ▾"))}
    {field("Size answers to", f'<div style="display: flex; align-items: flex-start; gap: 16px;">{segmented(["Band", "Chord", "Fixed"], "Band")}<div style="flex: 1;">{text_control("12", "u inset")}</div></div>', hint="Cap height fills the band: 129 u")}
    {field("Sweep", f'<div style="display: flex; gap: 16px;"><div style="flex: 1;">{text_control("202", "° from")}</div><div style="flex: 1;">{text_control("338", "° to")}</div></div>')}
    {field("Set within the sweep", segmented(["Start", "Centre", "End", "Justify"], "Justify"))}
    {field("Tracking", slider("−47", 0.12, " u"), error="Negative: the letters collide. Widen the sweep or condense the face.")}
    {field("Colour slot", pair_control(swatch("#2e2c28") + "Ink", "rank 1 of 2 ▾"))}
    <div style="flex: 1;"></div>
    <p style="margin: 0; font-size: 12px; line-height: 24px; color: {QUIET};">{link("Duplicate")} · {link("Remove")} · {link("Kern a pair")}</p>
  </aside>'''

def inspector_dress():
    row = lambda name, rank, hexv, cname, rule: f'''<tr>
      <td style="padding: 0 24px 23px 0; border-bottom: 1px solid {RULE}; font-size: 16px; line-height: 24px; vertical-align: top;">{swatch(hexv)}{name}<br><span style="font-size: 12px; color: {QUIET};">{rank}</span></td>
      <td style="padding: 0 0 23px; border-bottom: 1px solid {RULE}; font-size: 16px; line-height: 24px; vertical-align: top;">{cname}<br><span style="font-size: 12px; color: {QUIET};">{rule}</span></td></tr>'''
    def cw(name, colors, on=False):
        sws = "".join(f'<span style="width: 12px; height: 16px; background: {c};"></span>' for c in colors)
        return f'''<div style="display: flex; align-items: center; gap: 12px; height: 24px; padding: 0 8px; {f"background: {SHADED}; box-shadow: inset 2px 0 0 {ACCENT};" if on else ""}"><span style="display: flex; width: 36px; justify-content: flex-start;"><span style="display: flex; box-shadow: inset 0 0 0 1px {RULE};">{sws}</span></span><span style="font-size: 16px; line-height: 24px; font-weight: {700 if on else 400};">{name}</span>{f'<span style="flex: 1;"></span><span style="font-size: 12px; color: {QUIET};">wearing</span>' if on else ""}</div>'''
    colorways = f'''<div style="display: flex; flex-direction: column; border-top: 1px solid {RULE}; border-bottom: 1px solid {RULE}; padding: 4px 0;">{cw("Value", ["#f8f8f8", "#101010"])}{cw("Stadion", ["#e8e2d0", "#2a1a10"], True)}{cw("Brand Core", ["#faf8f4", "#e30613", "#111111"])}{cw("Paper &amp; Ink", ["#ffffff", "#0d0d0d"])}</div>'''
    return f'''<aside style="width: {FIELDS(3):.0f}px; flex: none; min-width: 0; display: flex; flex-direction: column; gap: 12px;">
    <div>
      <p style="margin: 0; font-size: 12px; line-height: 24px; color: {QUIET}; font-weight: 700;">Colorway · from Pandatone</p>
      <h3 style="margin: 0; font-size: 24px; line-height: 32px; font-weight: 700; letter-spacing: -0.015em;">Stadion</h3>
    </div>
    <table style="width: 100%; border-collapse: collapse;">
      <thead><tr><th style="text-align: left; color: {QUIET}; font-size: 12px; line-height: 24px; font-weight: 700; border-bottom: 1px solid {INK}; padding-bottom: 7px;">Slot</th><th style="text-align: left; color: {QUIET}; font-size: 12px; line-height: 24px; font-weight: 700; border-bottom: 1px solid {INK}; padding-bottom: 7px;">Wearing</th></tr></thead>
      <tbody>{row("Ground", "rank 0 · the ring", "#e8e2d0", "Vellum", "by rank: lightest")}{row("Ink", "rank 1 · the type", "#2a1a10", "Espresso", "by rank: darkest")}</tbody>
    </table>
    <p style="margin: 0; font-size: 12px; line-height: 24px; color: {QUIET};">Each slot resolves by a rule over the palette's snapshot. Nothing here holds a colour of its own. Stadion is as it was in Pandatone, checked 2 minutes ago.</p>
    {field("Colorways", colorways, hint=f'<a href="#" style="color: {QUIET};">Dress from a palette…</a> · <a href="#" style="color: {QUIET};">Check for drift</a>')}
    {field("Reference · stockholm.jpg, scaled to the badge", slider("50", 0.5, "%"))}
    <div style="flex: 1;"></div>
    <p style="margin: 0; font-size: 12px; line-height: 24px; color: {QUIET};"><a href="#" style="color: {QUIET};">Take off</a> · <a href="#" style="color: {QUIET};">Replace the reference…</a></p>
  </aside>'''

def colorway_strip():
    def chip(name, colors, on=False):
        sws = "".join(f'<span style="width: 16px; height: 24px; background: {c};"></span>' for c in colors)
        return f'''<button style="{FONT} display: flex; align-items: center; gap: 12px; padding: 12px 16px 11px 12px; border: 0; cursor: pointer; background: {SHADED if on else "transparent"}; box-shadow: inset 0 0 0 1px {INK if on else RULE}; color: {INK}; font-size: 16px; line-height: 24px;"><span style="display: flex; box-shadow: inset 0 0 0 1px {RULE};">{sws}</span>{name}</button>'''
    return f'''<div style="display: flex; align-items: center; gap: 8px; padding-top: 15px; border-top: 1px solid {RULE}; margin-top: 16px;">
    <span style="font-size: 12px; line-height: 24px; color: {QUIET}; font-weight: 700; margin-right: 8px;">Colorways</span>
    {chip("Value", ["#f8f8f8", "#101010"])}{chip("Stadion", ["#e8e2d0", "#2a1a10"], True)}{chip("Brand Core", ["#faf8f4", "#e30613", "#111111"])}{chip("Paper &amp; Ink", ["#ffffff", "#0d0d0d"])}
    <span style="flex: 1;"></span>
    {button("Dress from a palette…")}
  </div>'''

def sections(names, current):
    """The library's sections: a run of names under the title, the one shown
    in the weight, in ink. Not the accent: that is for where you are on the
    site, and this is where you are on the page."""
    return '<nav style="display: flex; gap: 24px;">' + "".join(
        f'<a href="#" style="text-decoration: none; font-size: 16px; line-height: 24px; color: {INK if n == current else QUIET}; font-weight: {700 if n == current else 400};">{n}</a>'
        for n in names) + '</nav>'

def page_head(title, mode):
    """The page head as the library draws it: the title and its facts, the
    actions beside them, the sections under. No rule: the rule is the one
    mark this style draws, and the masthead already drew one."""
    return f'''<div style="display: flex; flex-wrap: wrap; align-items: flex-start; justify-content: space-between; gap: 24px; padding: 24px 0 0;">
    <div style="display: flex; align-items: baseline; gap: 16px;">
      <h1 style="margin: 0; font-size: 32px; line-height: 48px; font-weight: 700; letter-spacing: -0.02em;">{title}</h1>
      <span style="font-size: 12px; line-height: 24px; color: {QUIET};">2 slots · 5 pieces · ink 782 × 952</span>
    </div>
    {button("Save", primary=True)}
    <div style="flex-basis: 100%;">{sections(["Compose", "Dress", "Export"], "Dress" if mode == "dress" else "Compose")}</div>
  </div>'''

def page(mode):
    inspector = inspector_dress() if mode == "dress" else inspector_compose()
    strip = ""
    return f'''{HEAD}
<div style="{FONT} width: 1440px; height: 900px; background: {PAPER}; color: {INK}; font-size: 16px; line-height: 24px; box-sizing: border-box; overflow: hidden;">
{masthead()}
<main style="max-width: 1312px; margin: 0 auto; padding: 0 24px; box-sizing: border-box;">
  {page_head("Stockholm Stadion", mode)}
  <div style="display: flex; gap: 24px; padding-top: 24px;">
    {tree()}
    {canvas(mode, construction=(mode != "dress"), reference=(mode == "dress"))}
    {inspector}
  </div>
  {strip}
</main>
</div>
{FOOT}'''

write("Compose", page("compose"))
write("Dress", page("dress"))

def sketch(kind):
    g = f'stroke="{INK}" fill="none" stroke-width="1.5"'
    t = f'stroke="{QUIET}" fill="none" stroke-width="1" stroke-dasharray="3 3"'
    s = {
      "ring": f'<ellipse cx="60" cy="50" rx="52" ry="40" {g}/><ellipse cx="60" cy="50" rx="34" ry="24" {g}/><path d="M22 50a38 28 0 0 1 76 0" {t}/>',
      "medallion": f'<ellipse cx="60" cy="50" rx="52" ry="40" {g}/><ellipse cx="60" cy="50" rx="40" ry="30" {t}/><circle cx="60" cy="50" r="14" {g}/>',
      "stack": f'<path d="M60 8 L84 50 L60 92 L36 50 Z" {g}/><path d="M48 32h24M42 50h36M48 68h24" {t}/>',
      "word": f'<path d="M8 50 L60 20 L112 50 L60 80 Z" {g}/><path d="M16 50 L60 26 L104 50 L60 74 Z" {t}/><path d="M28 50h64" {t}/>',
      "shield": f'<path d="M20 12h80v40c0 20-20 32-40 40C40 84 20 72 20 52z" {g}/><path d="M28 20h64" {t}/><path d="M28 30h64" {t}/>',
      "plate": f'<rect x="12" y="20" width="96" height="60" rx="8" {g}/><path d="M24 36h72M24 50h72M24 64h48" {t}/>',
    }[kind]
    return f'<svg width="120" height="100" viewBox="0 0 120 100" style="display: block;">{s}</svg>'

def card(kind, name, blurb, refname=None):
    ref = f'<span style="font-size: 12px; line-height: 24px; color: {QUIET};">After {refname}</span>' if refname else f'<span style="font-size: 12px; line-height: 24px; color: {QUIET};">&nbsp;</span>'
    return f'''<button style="{FONT} text-align: left; display: flex; flex-direction: column; gap: 0; padding: 24px 24px 23px; border: 0; cursor: pointer; background: transparent; box-shadow: inset 0 0 0 1px {RULE}; color: {INK};">
    <div style="padding-bottom: 24px;">{sketch(kind)}</div>
    <span style="font-size: 16px; line-height: 24px; font-weight: 700;">{name}</span>
    <span style="font-size: 12px; line-height: 24px; color: {QUIET};">{blurb}</span>
    {ref}
  </button>'''

shape = lambda name, svg, on=False: f'<button style="{FONT} display: flex; flex-direction: column; align-items: center; gap: 0; padding: 12px 12px 11px; border: 0; cursor: pointer; background: {SHADED if on else "transparent"}; box-shadow: inset 0 0 0 1px {INK if on else RULE}; color: {INK}; font-size: 12px; line-height: 24px;">{svg}{name}</button>'
sg = f'stroke="{INK}" fill="none" stroke-width="1.5"'
shapes = [
    ("Circle", f'<svg width="48" height="40" viewBox="0 0 48 40"><circle cx="24" cy="20" r="16" {sg}/></svg>'),
    ("Ellipse", f'<svg width="48" height="40" viewBox="0 0 48 40"><ellipse cx="24" cy="20" rx="20" ry="13" {sg}/></svg>'),
    ("Superellipse", f'<svg width="48" height="40" viewBox="0 0 48 40"><path d="M24 4c14 0 20 6 20 16s-6 16-20 16S4 30 4 20 10 4 24 4z" {sg}/></svg>', True),
    ("Rectangle", f'<svg width="48" height="40" viewBox="0 0 48 40"><rect x="5" y="8" width="38" height="24" {sg}/></svg>'),
    ("Rounded", f'<svg width="48" height="40" viewBox="0 0 48 40"><rect x="5" y="8" width="38" height="24" rx="6" {sg}/></svg>'),
    ("Lozenge", f'<svg width="48" height="40" viewBox="0 0 48 40"><path d="M24 4L44 20 24 36 4 20z" {sg}/></svg>'),
    ("Shield", f'<svg width="48" height="40" viewBox="0 0 48 40"><path d="M8 5h32v15c0 8-8 13-16 16-8-3-16-8-16-16z" {sg}/></svg>'),
    ("Path…", f'<svg width="48" height="40" viewBox="0 0 48 40"><path d="M6 30C10 6 22 4 26 14s10 8 16 2" {sg} stroke-dasharray="3 3"/></svg>'),
]
start = f'''{HEAD}
<div style="{FONT} width: 1440px; height: 900px; background: {PAPER}; color: {INK}; font-size: 16px; line-height: 24px; box-sizing: border-box; overflow: hidden;">
{masthead()}
<main style="max-width: 1312px; margin: 0 auto; padding: 0 24px; box-sizing: border-box;">
  <div style="padding: 24px 0 0;">
    <h1 style="margin: 0; font-size: 48px; line-height: 72px; font-weight: 700; letter-spacing: -0.028em;">Compose a badge</h1>
    <p style="margin: 24px 0 0; max-width: 620px; font-size: 16px; line-height: 24px;">Start from a composition, not a blank document. Each one is a container that derives regions and type set into them; everything on it can be changed once it is on the board.</p>
  </div>
  <div style="padding-top: 24px;">
    <p style="margin: 0 0 24px; font-size: 12px; line-height: 24px; font-weight: 700; color: {QUIET};">Composition</p>
    <div style="display: grid; grid-template-columns: repeat(6, minmax(0, 1fr)); gap: 24px;">
      {card("ring", "Ring", "Type follows the band over the top and back under the bottom; a pair holds the sides.", "Stockholm Stadion")}
      {card("medallion", "Medallion", "A ring with a child container in the field: one letter or a mark.", "Salt &amp; Sierra")}
      {card("stack", "Lozenge stack", "Lines down a tall lozenge, each taking the chord at its height.", "Le Dive")}
      {card("word", "Wide word", "One word across a wide lozenge, each letter the chord at its position.", "Giletti")}
      {card("shield", "Shield band", "A straight top edge to set along, and a field below it.")}
      {card("plate", "Plate", "A rounded plate with a block of lines and a knocked-out patch.")}
    </div>
  </div>
  <div style="display: flex; align-items: flex-end; gap: 24px; padding-top: 24px;">
    <div>
      <p style="margin: 0 0 24px; font-size: 12px; line-height: 24px; font-weight: 700; color: {QUIET};">Shape</p>
      <div style="display: flex; gap: 8px;">{"".join(shape(*s) for s in shapes)}</div>
    </div>
    <span style="flex: 1;"></span>
    <div style="display: flex; align-items: center; gap: 16px;">
      {button("Compose a ring on a superellipse", primary=True)}
      <span style="font-size: 12px; line-height: 24px; color: {QUIET};">Or <a href="#" style="color: {QUIET};">paste a document</a>.</span>
    </div>
  </div>
</main>
</div>
{FOOT}'''
write("Start", start)
json.dump({
  "artboards": [
    {"file": "Compose.dc.html", "title": "Compose", "x": 0, "y": 0, "w": 1440, "h": 900},
    {"file": "Dress.dc.html", "title": "Dress", "x": 1560, "y": 0, "w": 1440, "h": 900},
    {"file": "Start.dc.html", "title": "Start", "x": 3120, "y": 0, "w": 1440, "h": 900}
  ],
  "annotations": [
    {"id": "how-to-read", "x": 0, "y": -220, "w": 520, "text": "Compose: the construction lines are the controls, and handles belong to the selection. STOCKHOLM is selected, so its baseline is red with the sweep handles at its ends and a dot at each letter to kern from; select the ring and its edges get handles instead. The setting line is the dashed horizontal with the digits' locators crossed on it. The pin by the S is a real finding from the render: with DejaVu standing in for the reference face, justify had to go to negative tracking."},
    {"id": "dress-note", "x": 1560, "y": -160, "w": 520, "text": "Dress: the same badge wearing a Pandatone palette, over the reference at 50%. Colorways in the inspector swap instantly; the table shows the rule each slot resolves by, and drift is asked for, never applied."},
    {"id": "start-note", "x": 3120, "y": -120, "w": 520, "text": "Start: a new badge picks a composition and a shape. The three references are the first three compositions."}
  ],
  "launch": {"view": "canvas"}
}, open("canvas/canvas.json", "w"), indent=2)
