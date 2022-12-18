Rails.application.routes.draw do
  devise_for :users
  root "films#index"
  get 'films/index'
  get 'films/film'
  post 'films/film', :to => "films#add_comment_to_films"
  post 'rating', :to => "films#add_rating"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
