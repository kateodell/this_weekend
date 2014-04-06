ThisWeekend::Application.routes.draw do
  root 'home#index'

  get 'events' => 'home#show'
end
