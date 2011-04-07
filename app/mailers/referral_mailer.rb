class ReferralMailer < ActionMailer::Base
  add_template_helper ApplicationHelper
  default :from => "admin@shop2.com"

  def share referral, friends
    @referral = referral

    mail(
      to: friends,
      from: "#{@referral.referer.name}<#{@referral.referer.email}>",
      subject: "Check this out - #{@referral.friend_offer_description}"
    )
  end
end
