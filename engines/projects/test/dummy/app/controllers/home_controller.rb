# Outside the door, so a browser test has somewhere to plant its cookie.
class HomeController < ActionController::Base
  def show
    render html: "Dummy".html_safe, layout: false
  end
end
