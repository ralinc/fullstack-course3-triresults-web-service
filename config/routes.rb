Rails.application.routes.draw do

  namespace :api do
    resources :races do
      resources :results
    end

    resources :racers do
      resources :entries
    end
  end

end
