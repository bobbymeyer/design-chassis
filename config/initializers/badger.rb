# What Badger takes from the chassis: where its fonts are.
#
# The fonts a badge may name. The chassis ships Archivo for its own shell,
# and Badger sets type in it: a badge says `font: archivo-variable-latin`
# and shapes through the same file the pages are set in.
#
# Its palettes it takes from Pandatone directly, through Pandatone's own
# dresser, which asks the Pandatone in this process when no PANDATONE_URL is
# set — so the chassis has nothing to say about them. That is the one thing
# the chassis used to say about two tools at once, and it no longer has to.
Badger.font_directories = [ Rails.root.join("app/assets/fonts") ]
