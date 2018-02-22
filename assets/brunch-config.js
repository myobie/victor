exports.files = {
  javascripts: {
    joinTo: 'js/app.js'
  },
  stylesheets: {
    joinTo: 'css/app.css'
  }
}

exports.conventions = {
  assets: /^(static)/
}

exports.paths = {
  watched: ['static', 'css', 'js', 'vendor'],
  public: '../priv/static'
}

exports.plugins = {
  babel: {
    presets: ['@babel/preset-env'],
    ignore: [/vendor/]
  }
}

exports.modules = {
  autoRequire: {
    'js/app.js': ['js/app']
  }
}

exports.npm = {
  enabled: true
}
