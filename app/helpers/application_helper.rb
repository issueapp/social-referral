module ApplicationHelper
  def title title
    content_for :title, title
    title
  end

  def url_for_referral(referral, params = {})
    host = Rails.env.production? ? "http://todo.read.from.conf/" : 'http://socialreferral.dev/'
    "#{host}#{referral.short_url}?#{params.to_query}"
  end
end
