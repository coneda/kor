module.exports = function(config) {
  config.set({
    basePath: '',
    frameworks: ['jasmine'],
    files: [
      'widgets/spec/helper.js',
      'public/app.css',
      'public/app-noboot.js',
      'widgets/spec/tags/**/*.spec.js'
    ],
    exclude: [],
    preprocessors: {},
    reporters: ['progress'],
    port: 9876,
    colors: true,
    logLevel: config.LOG_INFO,
    autoWatch: true,
    browsers: [
      // 'Firefox', 'Chromium',
      'PhantomJS'
    ],
    singleRun: false,
    concurrency: Infinity
  })
}
