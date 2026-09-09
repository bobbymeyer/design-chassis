require "rails/engine"

# What the engine is built on. Required here rather than left to the host's
# Gemfile: a gem's dependencies are resolved by Bundler and loaded by nobody.
require "propshaft"
require "importmap-rails"
require "turbo-rails"
require "stimulus-rails"
require "its-swiss"

# Nothing else. Not Pandatone, not Stripeclub, not anything a project
# gathers from: what a source reads is the host's to say.

module Projects
  # A mountable engine: its own controllers, routes, views, migrations and
  # stylesheets, under one namespace and one table prefix.
  #
  #   mount Projects::Engine, at: "/projects"
  #
  # Two things it takes from the host. The door: every screen inherits from
  # the host's ApplicationController and every API endpoint from the host's
  # API controller (Projects.base_controller_class). The shell: the engine's
  # layout fills its slots and renders the host's layouts/application around
  # them. And one more, which is this engine's whole point — the sources,
  # registered with Projects.source, which are the host doing the one thing
  # only a host may do: knowing about more than one tool at once.
  class Engine < ::Rails::Engine
    isolate_namespace Projects

    # The engine's migrations run with the host's rather than being copied in.
    initializer "projects.migrations" do |app|
      unless app.root.to_s.start_with?(root.to_s)
        config.paths["db/migrate"].expanded.each do |path|
          app.config.paths["db/migrate"] << path
        end
      end
    end
  end
end
