# The bay: what is mounted and where. It reads the engine list and nothing
# else, because there is nothing else in the chassis to read.
class HomeController < ApplicationController
  def show
    @mounts = Chassis::Engines.all
  end
end
