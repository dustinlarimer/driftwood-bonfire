module.exports = (match) ->
  match '', 'home#index'

  match 'auth-callback', 'auth#callback'
  match 'login', 'auth#login'
  match 'logout', 'auth#logout'
  match 'settings', 'users#settings'
  match 'join', 'users#setup'

  #match 'browse', 'canvases#index'
  #match ':id', 'canvases#show', constraints: {id: /^\d+$/}
  #match ':id/editor', 'canvases#edit', constraints: {id: /^\d+$/}

  match ':handle', 'users#show'