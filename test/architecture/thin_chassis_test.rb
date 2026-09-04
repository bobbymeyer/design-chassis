require "test_helper"

# The chassis is server, database, auth, shell and the engine list. Nothing
# else, ever. Its health is its emptiness, and this is the scale it is weighed
# on. A failure here is a capability that has gone homeless: move it into an
# engine, do not loosen the test.
class ThinChassisTest < ActiveSupport::TestCase
  ROOT = Rails.root

  # Everything Active Record the chassis is allowed to have: an account and
  # the sessions it holds.
  AUTH_MODELS = %w[ application_record current session user ].freeze

  test "the only models are the auth models" do
    models = Dir[ROOT.join("app/models/**/*.rb")].map { |path| File.basename(path, ".rb") }
    assert_equal AUTH_MODELS.sort, models.sort,
      "app/models holds #{(models - AUTH_MODELS).inspect}: domain logic belongs in an engine"
  end

  test "the only tables are the auth tables" do
    tables = ActiveRecord::Base.connection.tables - %w[ schema_migrations ar_internal_metadata ]
    assert_equal %w[ sessions users ], tables.sort
  end

  # The one rule: tools are called through their public interface, never
  # their internals. Pandatone.palette(id), never Pandatone::Palette.where.
  # An engine's namespace may appear in the chassis only to name the engine
  # itself, which is what mounting it takes.
  test "no engine's internals are named anywhere in the chassis" do
    assert_kind_of Array, Chassis::Engines.all

    Chassis::Engines.all.each do |mount|
      namespace = mount.engine.delete_suffix("::Engine")

      chassis_files.each do |path|
        File.read(path).scan(/#{namespace}::\w+/).each do |reference|
          assert_equal mount.engine, reference,
            "#{relative(path)} reaches into #{reference}; call #{namespace}'s public methods instead"
        end
      end
    end
  end

  # Querying is what a domain does. The chassis queries two things, and only
  # from the files that are its authentication.
  test "no queries outside the auth" do
    queries = /\.(where|find_by|find_by!|joins|includes|order|pluck|group|having)\(/

    (chassis_files - auth_files).each do |path|
      File.foreach(path).with_index(1) do |line, number|
        assert_no_match queries, line, "#{relative(path)}:#{number} runs a query: that is a domain's job"
      end
    end
  end

  test "no color arithmetic and no SVG construction" do
    smells = /\b(hsl|hsla|oklch|rgb|hex_to|to_hex|Nokogiri::XML::Builder|<svg|content_tag\(:svg|tag\.svg)\b/i

    (chassis_files - [ ROOT.join("app/assets/stylesheets/theme.css").to_s ]).each do |path|
      File.foreach(path).with_index(1) do |line, number|
        assert_no_match smells, line, "#{relative(path)}:#{number} looks like a design calculation: it belongs in an engine"
      end
    end
  end

  private
    def chassis_files
      Dir[ROOT.join("{app,config,lib}/**/*.{rb,erb,css,js}")].reject { |path| path.include?("/assets/builds/") }
    end

    def auth_files
      %w[
        app/channels/application_cable/connection.rb
        app/controllers/concerns/authentication.rb
        app/controllers/passwords_controller.rb
        app/controllers/registrations_controller.rb
        app/controllers/sessions_controller.rb
        app/models/user.rb
        app/models/session.rb
      ].map { |path| ROOT.join(path).to_s }
    end

    def relative(path) = Pathname(path).relative_path_from(ROOT).to_s
end
