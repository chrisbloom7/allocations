Rails.application.routes.draw do
  root "allocations#index"
  post "/allocation", to: "allocations#show"
end
