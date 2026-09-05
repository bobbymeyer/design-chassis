# Where Stripeclub's palettes come from.
#
# Stripeclub composes in value and asks Pandatone what those values are
# wearing. Both are mounted here, in one process, so the question is a method
# call. Left alone the engine would reach for its HTTP client instead, which
# on this machine means talking to itself through the proxy and carrying a
# token to its own front door — the cross-service hop the chassis exists to
# delete.
#
# This is the chassis doing the one thing only the chassis may do: knowing
# about two tools at once. It is engine-method-calls and glue, and there is
# no third line it could grow.
#
# Stripeclub knows Pandatone by its wire format and by nothing else, and that
# format is JSON's: string keys. Handing over exactly that is what keeps this
# an agreement between two published interfaces. The engine happens to
# normalize what it is given, so symbols would work today — but that is a
# tolerance inside the engine rather than a promise it makes, and leaning on
# it would be the chassis depending on an internal.
#
# Summaries carry no colors and the colors are the whole of what Stripeclub
# asks about, so each palette is read in full. The HTTP client this replaces
# paid the same cost, in requests rather than queries.
Stripeclub.palette_source = -> {
  Pandatone.palettes.filter_map { |summary| Pandatone.palette(summary[:id])&.deep_stringify_keys }
}
