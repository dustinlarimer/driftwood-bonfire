module.exports = (match) ->
  match '', 'home#index'
  match 'auth-callback', 'auth#callback'
  match 'login', 'auth#login'
  match 'logout', 'auth#logout'
  match 'settings', 'users#settings'
  match 'join', 'users#join'
  
  match ':id', 'canvases#show', constraints: {id: /^\d+$/}
  match ':id/edit', 'canvases#edit', constraints: {id: /^\d+$/}
  
  match ':handle', 'profiles#latest'
  match ':handle/projects', 'profiles#projects'
  match ':handle/collaborators', 'profiles#collaborators'