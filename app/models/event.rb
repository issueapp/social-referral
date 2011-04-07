class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  field :type
  field :source
  field :referer # referer url
  field :ip
  field :user_agent

  belongs_to :referral
  belongs_to :referee, class_name: 'User'

end
