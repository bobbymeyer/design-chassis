# The one place two tools meet, and the whole of what the chassis does about
# it: Stripeclub dresses a pattern in a palette it did not make, and asks its
# host where palettes come from. Here they come from Pandatone, in the same
# process, through Pandatone's public interface — the same hashes its API
# sends. Stripeclub never learns which, and Pandatone never learns it was
# asked. A method call and a map; no colour arithmetic, no HTTP.
Stripeclub.palette_source = -> { Pandatone.palettes.map { |summary| Pandatone.palette(summary[:id]) } }
