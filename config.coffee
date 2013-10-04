exports.config =
  # See http://brunch.io/#documentation for docs.
  files:
    javascripts:
      joinTo:
        'javascripts/editor.js'     : /^app(\/|\\)views(\/|\\)editor/
        'javascripts/app.js'        : /^app(\/|\\)(?!views(\/|\\)editor)/
        'javascripts/vendor.js'     : /^(?!app)/
        #'javascripts/app.js'       : /^app/
        #'javascripts/vendor.js'    : /^(?!app)/

    stylesheets:
      joinTo: 
        'stylesheets/editor.css'    : /^app(\/|\\)views(\/|\\)editor/
        'stylesheets/app.css'       : /^(?!app(\/|\\)views(\/|\\)editor)/
        #'stylesheets/app.css'

    templates:
      joinTo: 
        'javascripts/editor.js'     : /^app(\/|\\)views(\/|\\)editor/
        'javascripts/app.js'        : /^app(\/|\\)(?!views(\/|\\)editor)/
        #'javascripts/app.js'