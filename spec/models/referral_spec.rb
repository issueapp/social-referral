require 'spec_helper'

describe Referral do
  let :referral do
    Fabricate :referral
  end

  context "when event occurs" do
    let :events do
      [
        Fabricate(:event, type: 'visit', source: 'facebook', referral: referral),
        Fabricate(:event, type: 'visit', source: 'twitter', referral: referral),
        Fabricate(:event, type: 'visit', source: 'email', referral: referral),
        Fabricate(:event, type: 'signup', source: 'twitter', referral: referral)
      ]
    end

    it "aggregates event counter" do
      referral.aggregate! events.first
      referral.counter_hash.should == {'visits' => 1, 'facebook_visits' => 1}

      referral.aggregate! events
      referral.counter_hash.should == {'visits' => 4, 'facebook_visits' => 2, 'twitter_visits' => 1, 'email_visits' => 1, 'signups' => 1, 'twitter_signups' => 1}

      referral.aggregate! Fabricate :event
      referral.counter_hash.should == {'visits' => 4, 'facebook_visits' => 2, 'twitter_visits' => 1, 'email_visits' => 1, 'signups' => 1, 'twitter_signups' => 1}
    end
  end
end
