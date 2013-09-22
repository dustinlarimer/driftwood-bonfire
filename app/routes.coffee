module.exports = (match) ->
  match '', 'home#index'

  # Authentication
  match 'auth-callback', 'auth#callback'
  match 'login', 'auth#login'
  match 'logout', 'auth#logout'
  #match 'join', 'users#newProfile'
  #match 'create', 'users#createUser'
  match 'settings', 'users#settings'

  # Canvases
  #match 'browse', 'canvases#index'
  #match ':id', 'canvases#show', constraints: {id: /^\d+$/}
  #match ':id/editor', 'canvases#edit', constraints: {id: /^\d+$/}

  # User Profiles
  #match 'members', 'users#index'
  match ':handle', 'users#show'