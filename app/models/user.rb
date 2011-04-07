class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :email

  has_many :referrals, inverse_of: :referer
  has_and_belongs_to_many :referred, class_name: 'Referral', inverse_of: :referees

  validates :email, uniqueness: true,
                    presence: true,
                    email: true
end
