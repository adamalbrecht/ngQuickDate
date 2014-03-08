# an example karma.conf.coffee
module.exports = (config) ->
  config.set
    autoWatch: true
    frameworks: ['jasmine']
    browsers: ['PhantomJS']
    preprocessors: {
      '**/*.coffee': ['coffee'],
    }
    coffeePreprocessor: {
      options: {
        bare: true,
        sourceMap: false
      }
      transformPath: (path) -> path.replace(/\.js$/, '.coffee')
    }
    files: [
      'bower_components/angular/angular.js'
      'bower_components/angular-mocks/angular-mocks.js'
      'bower_components/jquery/jquery.js'
      'bower_components/momentjs/moment.js'
      'bower_components/moment-timezone/moment-timezone.js'
      'bower_components/moment-timezone/moment-timezone-data.js'
      'vendor/browserTrigger.js'
      'src/*.coffee'
      'spec/*.coffee'
    ]
