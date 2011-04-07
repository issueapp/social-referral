class Url
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug

  # Base62 short url or customized
  field :short_url
  field :url
  field :views,     :type => Integer, :default => 0
  
  index :short_url, :background => true, :unique => true
  
  belongs_to :forwardable, :inverse_of => :url, :polymorphic => true
  belongs_to :referer, class_name: 'User', inverse_of: :referral_urls

  validates :short_url, :presence => true,
                        :uniqueness => true

  before_validation :generate_short_url, :on => :create

  # Atomic increament counter
  class Code
    include Mongoid::Document
    field :count, :type => Integer, :default => 0

    def self.generate!      
      instance = self.first || self.create
      code = Code._collection.master.collection.find_and_modify(
        :query  => {"_id" => instance.id},
        :update => {"$inc"=> {:count => 1}},
        :new    => true,
        :upsert => true
      )
      code["count"].encode62
    end
  end
  
  private
  
    # Note: could be race conditions
    def generate_short_url
      if self.short_url.blank?
        self.short_url = Code.generate!
      else
        self.short_url = self.short_url.to_url
      end
    end
end
  
