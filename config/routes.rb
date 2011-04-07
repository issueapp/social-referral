Ime::Application.routes.draw do
  resources :offers

  resources :referrals, only: [:new, :create, :show] do
    member do
      get :share
      get :offer

      get :email
      post :share_by_email
    end
  end

  # external third party API to track referral events
  put '/referrals/:id/register/:event' => 'referrals#register'

  # referral short url handler
  get '/:code' => 'referrals#redirect'
end
