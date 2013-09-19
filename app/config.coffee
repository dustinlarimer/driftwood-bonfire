config =
  development:
    firebase: 'https://ideavis-test.firebaseio.com'
    singly:
      singlyURL: 'https://api.singly.com'
      clientID: '6060442bd5e6319ad186b65602e77da1'
      redirectURI: 'http://localhost:3333/auth-callback'
      providers: ['Facebook', 'Google', 'LinkedIn', 'Twitter']
  production:
    firebase: ''
    singly:
      singlyURL: 'https://api.singly.com'
      clientID: ''
      redirectURI: ''

switch window.location.hostname
  when 'alpha.ideavis.co', 'ideavis-alpha-core.herokuapp.com', 'ideavis-alpha-client.herokuapp.com'
    env = "production"
  else env = "development"

module.exports = config[env]