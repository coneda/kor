module.exports = function(config) {
  config.set({
    basePath: '',
    frameworks: ['jasmine-ajax', 'jasmine'],
    files: [
      'public/app.css',
      'public/app-noboot.js',
      'widgets/spec/helper.js',
      'widgets/spec/tags/**/*.spec.js'
    ],
    exclude: [],
    preprocessors: {},
    reporters: ['progress'],
    port: 9876,
    colors: true,
    logLevel: config.LOG_INFO,
    browserConsoleLogOptions: {
      level: "debug", format: "%b %T: %m", terminal: true
    },
    autoWatch: true,
    browsers: [
      // 'Firefox',
      'Chromium'
      // 'PhantomJS'
    ],
    singleRun: false,
    concurrency: Infinity,
    client: {
      captureConsole: true
    }
  })
}
