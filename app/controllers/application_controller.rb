class ApplicationController < ActionController::Base
  include ExceptionHandler
  include Response

  protect_from_forgery with: :null_session

  def index
  end

  def create
    unless request_verified?
      puts "unauthorized"
      json_response :status => :unauthorized
    end
    #if setting up endpoint
    if params["challenge"]
      challenge = { :challenge => params["challenge"]}
      json_response challenge
    end

    #handle user_update event
    event_type = params.dig("event", "type")
    case event_type
    when "user_change"
      user_params = params.dig("event","user")
      puts "userchange. New user is #{user_params}"
      create_or_update_user_service = SlackUserService.new(user_params)
      create_or_update_user_service.perform
    else
      puts "something else"
    end
    json_response "success"
  end

  private

  def request_verified?
    timestamp = request.headers["X-Slack-Request-Timestamp"]
    signature = request.headers["X-Slack-Signature"]
    signing_secret = ENV.fetch("SLACK_SIGNING_SECRET")

    if Time.at(timestamp.to_i) < 5.minutes.ago
      return false # expired
    end

    basestring = "v0:#{timestamp}:#{request.body.read}"
    my_signature = "v0=#{OpenSSL::HMAC.hexdigest("SHA256", signing_secret, basestring)}"

    ActiveSupport::SecurityUtils.secure_compare(my_signature, signature)
  end
end