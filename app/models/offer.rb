class Offer
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes

  field :url
  field :description
  field :expired_at, :type => DateTime

  def expired?
    expired_at && expired_at < Time.now
  end

  def referral_count
    Referral.count(conditions: {offer_id: self.id})
  end
end
