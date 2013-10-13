exports.config =
  # See http://brunch.io/#documentation for docs.
  files:
    javascripts:
      joinTo:
        'javascripts/editor.js'     : /^app(\/|\\)(views|models)(\/|\\)editor/
        'javascripts/app.js'        : /^app(\/|\\)(?!(views(\/|\\)editor)|models(\/|\\)editor)/
        'javascripts/vendor.js'     : /^(?!app)/

    stylesheets:
      joinTo: 'stylesheets/app.css'
        #'stylesheets/editor.css'    : /^app(\/|\\)views(\/|\\)editor/
        #'stylesheets/app.css'       : /^(?!app(\/|\\)views(\/|\\)editor)/

    templates:
      joinTo:
        'javascripts/editor.js'     : /^app(\/|\\)views(\/|\\)editor/
        'javascripts/app.js'        : /^app(\/|\\)(?!views(\/|\\)editor)/