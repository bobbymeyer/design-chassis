# Changelog

Semver. The API is versioned separately, under its own path, and is not what
this file numbers.

## Unreleased

### Added

- **The first version.** A project is a name and a tag, optionally under
  another project. What it shows is what the host's registered sources
  answer when asked for the tag, placed by one rule: an item lands on the
  deepest project whose tags it all carries.

  Kept out of the engine on purpose: any knowledge of which tools exist. The
  gemspec depends on no tool, and `Projects.source` is where a host says
  what to ask.
