require_relative "lib/projects/version"

Gem::Specification.new do |spec|
  spec.name        = "projects"
  spec.version     = Projects::VERSION
  spec.authors     = [ "Bobby Meyer" ]
  spec.email       = [ "bobby@bobbymeyer.com" ]
  spec.homepage    = "https://github.com/bobbymeyer/design-chassis"
  spec.summary     = "Named projects that gather what the other tools have tagged, as a Rails engine."
  spec.description = <<~TEXT.strip
    A project is a name and a tag. It gathers whatever the tools around it
    have tagged with it, so a body of work can be looked at together and
    followed back into the tool that holds each piece. Subprojects narrow:
    something carrying a subproject's whole line of tags lands there rather
    than at the top.

    Projects knows about no tool in particular. A host registers a source per
    tool it mounts, each a name and a lambda that answers with plain data.
  TEXT
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # Not published to RubyGems. It lives in the chassis's repository for now,
  # taken as a path gem; extracting it is moving the directory and changing
  # one line of the Gemfile.
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "README.md", "CHANGELOG.md"].select { |path| File.file?(path) }
  end

  spec.add_dependency "rails", ">= 8.0", "< 9"
  # The typographic style every screen is set in, declared here rather than
  # taken from the host on faith.
  spec.add_dependency "its-swiss", ">= 1.0"
  spec.add_dependency "propshaft", ">= 1.0", "< 3"
  spec.add_dependency "importmap-rails", ">= 2.0", "< 4"
  spec.add_dependency "turbo-rails", ">= 2.0", "< 3"
  spec.add_dependency "stimulus-rails", ">= 1.3", "< 2"

  # No dependency on Pandatone, on Stripeclub, or on any other tool, and
  # there never will be. What this engine gathers arrives through
  # Projects.source, which the host fills.
end
