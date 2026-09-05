require "test_helper"

# The list of mounted engines is the one place the chassis knows about more
# than one tool. These are the terms every entry on it has to meet.
class Chassis::EnginesTest < ActiveSupport::TestCase
  test "every mount is a name, a path and an engine" do
    assert_kind_of Array, Chassis::Engines.all

    Chassis::Engines.all.each do |mount|
      assert mount.name.present?, "a mount needs a name for the nav"
      assert mount.path.start_with?("/"), "#{mount.name} is mounted at #{mount.path}, which is not a path"
      assert mount.engine.end_with?("::Engine"), "#{mount.name} names #{mount.engine}, which is not a Rails engine"
    end
  end

  test "no two mounts share a path" do
    paths = Chassis::Engines.all.map(&:path)
    assert_equal paths.uniq, paths
  end

  test "no mount takes the root, which is the chassis's own" do
    assert_not_includes Chassis::Engines.all.map(&:path), "/"
  end

  test "the mounts are Pandatone and Stripeclub, in the order they were extracted" do
    assert_equal [ [ "Pandatone", "/pandatone", Pandatone::Engine ], [ "Stripeclub", "/stripeclub", Stripeclub::Engine ] ],
      Chassis::Engines.all.map { |mount| [ mount.name, mount.path, mount.constant ] }
  end

  test "the routes mount exactly what the list says, at the paths it says" do
    mounted = Rails.application.routes.routes.filter_map do |route|
      app = route.app.app
      route.path.spec.to_s if app.is_a?(Class) && app < Rails::Engine && app != ItsSwiss::Engine
    end

    assert_equal Chassis::Engines.all.map(&:path).sort, mounted.sort
  end
end
