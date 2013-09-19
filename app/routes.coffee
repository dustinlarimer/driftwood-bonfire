module.exports = (match) ->
  match '', 'home#index'

  # Authentication
  match 'auth-callback', 'auth#callback'
  match 'login', 'auth#login'
  match 'logout', 'auth#logout'

  # Users
  match ':handle', 'users#show'