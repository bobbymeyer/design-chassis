# What Badger takes from the chassis: where its palettes come from, and
# where its fonts are.
#
# Badger composes a badge in value and asks Pandatone what those values are
# wearing, exactly as Stripeclub does; see config/initializers/stripeclub.rb
# for why this is a method call and not a request, and why it hands over
# Pandatone's wire format with string keys. This is the chassis doing the one
# thing only the chassis may do: knowing about two tools at once.
Badger.palette_source = -> {
  Pandatone.palettes.filter_map { |summary| Pandatone.palette(summary[:id])&.deep_stringify_keys }
}

# The fonts a badge may name. The chassis ships Archivo for its own shell,
# and Badger sets type in it: a badge says `font: archivo-variable-latin`
# and shapes through the same file the pages are set in.
Badger.font_directories = [ Rails.root.join("app/assets/fonts") ]
