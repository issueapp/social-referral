class ReferralsController < InheritedResources::Base
  extend ActiveSupport::Memoizable

  helper_method :referral

  # GET /referrals/new
  #
  # params
  #   incentive_offer=:offer_id
  #   friend_offer=:offer_id
  def new
    @incentive_offer = Offer.find(params[:incentive_offer])
    @friend_offer = Offer.find(params[:friend_offer])
    new!
  end

  # POST /referrals
  def create
    referer = User.find_or_create_by(email: params[:email]).tap do |referer|
      params[:name] && referer.update_attribute(:name, params[:name])
    end
    referral = Referral.create(
      incentive_offer_id: params[:incentive_offer_id],
      friend_offer_id: params[:friend_offer_id],
      referer: referer)

    create! { share_referral_path(referral) }
  end

  # PUT /referrals/:id/register/:event
  #
  # params:
  #   name=:referee_name
  #   email=:referee_email
  #
  # Our api to external third party to track referral events
  def register(event_type = 'visit')
    @referral ||= referral

    referee = User.find_or_create_by(email: params[:email])
    if referee
      referee.name ||= params[:name]
      @referral.referees << referee
    end

    params[:event] && event_type = params[:event]
    event_details = {type: event_type, referral_id: @referral.id, referee_id: referee.try(:id), source: params[:src],
      referer: request.referer, ip: request.remote_ip, user_agent: request.user_agent}
    event = Event.create(event_details)
    @referral.aggregate! event

    if request.xhr?
      head :no_content
    end
  end

  # GET /referrals/:id/offer
  def offer
    register 'visit'
  end

  # GET /referrals/:id/share
  def share
  end

  # POST /referrals/:id/share_by_email
  def share_by_email
    ReferralMailer.share(referral, params[:emails]).deliver
    @delivered = true

    render :email
  end

  # GET /referrals/:id/email
  def email
    #@referral = Referral.find(params[:id])
  end

  # GET /:code
  #
  # params
  #   src=facebook|twitter|email
  #
  # redirect short url to display offer
  def redirect
    url = Url.first(conditions: {short_url: params[:code]})
    if url
      referral = url.forwardable
      redirect_to offer_referral_path(referral, src: params[:src])
    else
      # TODO handle exception
    end
  end

private

  def referral
    Referral.find(params[:id])
  end
  memoize :referral
end
