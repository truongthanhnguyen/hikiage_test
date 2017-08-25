Rails.application.routes.draw do
  resources :orders
  get "ipn_process" => "orders#ipn_process"

end
