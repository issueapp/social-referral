class Counter
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :referral

  def self.define_incrementor counter
    "increment_#{counter}".tap do |method|
      counter = counter.to_sym
      class_eval do
        field counter, type: Integer

        define_method method.to_sym do
          write_attribute(counter, read_attribute(counter).to_i + 1)
        end
      end
    end
  end

  %w[
    visits
    facebook_visits
    twitter_visits
    email_visits

    signups
    facebook_signups
    twitter_signups
    email_signups
  ].each do |predefined_counter|
    define_incrementor predefined_counter
  end

  class IncrementorMatcher
    attr_accessor :counter

    def initialize method
      self.counter = $1 if method.to_s =~ /^increment_(\w+)$/
    end

    def match?
      counter.present?
    end
  end

  def method_missing name, *args
    matcher = IncrementorMatcher.new(name)
    if matcher.match?
      incrementor_method = self.class.define_incrementor(matcher.counter)
      public_send(incrementor_method)
    else
      super
    end
  end

  def respond_to? method
    matcher = IncrementorMatcher.new(method)
    matcher.match? || super
  end

  def to_hash
    attributes
  end

end
