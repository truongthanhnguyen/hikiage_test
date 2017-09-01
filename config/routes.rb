Rails.application.routes.draw do
  resources :orders do
    get :authorize, :capture, :refund
  end
  get "ipn_process" => "orders#ipn_process"

end
