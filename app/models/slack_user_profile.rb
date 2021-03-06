class SlackUserProfile < ApplicationRecord
  # model association
  belongs_to :slack_user
  # validation
  validates_presence_of :team, :slack_user
  validates_uniqueness_of :slack_user

  def map_slack_params_to_attributes(slack_params, slack_user)
    status_expiration = slack_params.dig("status_expiration") ?
      (Time.at(slack_params["status_expiration"])) : nil

    {
      title: slack_params["title"],
      phone: slack_params["phone"],
      skype: slack_params["skype"],
      avatar_hash: slack_params["avatar_hash"],
      real_name: slack_params["real_name"],
      display_name: slack_params["display_name"],
      real_name_normalized: slack_params["real_name_normalized"],
      display_name_normalized: slack_params["real_name_normalized"],
      email: slack_params["email"],
      image_original: slack_params["image_original"],
      status_expiration: status_expiration,
      status_emoji: slack_params["status_emoji"],
      status_text: slack_params["status_text"],
      team: slack_params["team"],
      slack_user: slack_user
    }
  end
end
