class OffersController < InheritedResources::Base
  extend ActiveSupport::Memoizable

  helper_method :offer

  def create
    create! { collection_url }
  end

  def update
    update! { collection_url }
  end

  def destroy
    destroy! { collection_url }
  end

private

  def offer
    Offer.find params[:id]
  end
  memoize
end
