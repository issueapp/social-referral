class Referral
  include Mongoid::Document
  extend ActiveSupport::Memoizable

  # the incentive to refer
  # and the incentive for friends to accept offer
  belongs_to :incentive_offer, class_name: 'Offer'
  belongs_to :friend_offer, class_name: 'Offer'

  # short url
  has_one :url, autosave: true, dependent: :destroy, inverse_of: :forwardable

  belongs_to :referer, class_name: 'User'
  has_and_belongs_to_many :referees, class_name: 'User', inverse_of: :referred do
    def << referee
      return super unless any?{|ref| ref.email == referee.email}
    end
  end

  has_one :counter

  before_create :generate_referral_url

  delegate :short_url, to: :url

  delegate :url, :description, to: :incentive_offer, prefix: true
  delegate :url, :description, to: :friend_offer, prefix: true

  def counter_hash
    hash = counter && counter.attributes.reject{|key| key =~ /^(?:_|referral_id|updated_at|created_at)/ }
    hash.tap {|h| h.try(:default=, 0)} || Hash.new(0)
  end
  memoize :counter_hash

  def aggregate! events
    (counter || build_counter).tap do |counter|
      [events].flatten.each do |event|
        if event.referral == self
          counter.public_send("increment_#{event.type}s")
          counter.public_send("increment_#{event.source}_#{event.type}s") if event.source.present?
          counter.save!
        end
      end
    end
  end

private

  def generate_referral_url
    build_url forwardable: self
  end
end
