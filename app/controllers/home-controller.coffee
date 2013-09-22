Controller = require 'controllers/base/controller'
HeaderView = require 'views/home/header-view'
HomePageView = require 'views/home/home-page-view'

module.exports = class HomeController extends Controller
  beforeAction: ->
    super
    @compose 'header', HeaderView, region: 'header'

  index: ->
    console.log 'accessToken: ' + localStorage.getItem 'accessToken'
    @view = new HomePageView region: 'main'