# The door for scripts. Every engine's API inherits from this: a token and
# nothing else. The session cookie the browser carries is deliberately not
# accepted here — honoring it would make every page on the internet able to
# drive the API from a signed-in browser, which is the whole of what CSRF is,
# and ActionController::API brings no forgery protection to stand in the way.
class ApiController < ActionController::API
  before_action :authenticate_client

  private
    def authenticate_client
      Current.api_user = client_from_token

      render json: { error: "Unauthorized" }, status: :unauthorized unless Current.user
    end

    # Rails reads both spellings of the header, so a client sending the older
    # `Token abc` is not turned away for a reason nobody could guess from a 401.
    def client_from_token
      token, _options = ActionController::HttpAuthentication::Token.token_and_options(request)

      User.find_by(api_token: token) if token.present?
    end
end
