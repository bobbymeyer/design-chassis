# Making the account. The chassis is one person's, so there is exactly one way
# to be allowed an account: arrive first. Once one exists the door is shut,
# and a second account, should that day come, is a console away.
class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  before_action :redirect_if_shut
  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { redirect_to new_registration_path, alert: "Try again later." }

  def new
    @user = User.new
  end

  def create
    @user = User.new(params.expect(user: [ :email_address, :password, :password_confirmation ]))

    if @user.save
      start_new_session_for @user
      redirect_to after_authentication_url
    else
      render :new, status: :unprocessable_content
    end
  end

  private
    def redirect_if_shut
      redirect_to new_session_path, alert: "The chassis already has its account. Sign in." if User.any?
    end
end
