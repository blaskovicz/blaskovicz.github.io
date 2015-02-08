module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    sass:
      dist:
        files:
          'main.css': '*.scss'
    htmlhint:
      index:
        options:
          'tag-pair': true
          'id-unique': true
          'src-not-empty': true
        src: [
          'index.html'
        ]
    coffee:
      compile:
        files:
          'app.js': [
            'coffee/app.coffee'
            'coffee/filters/*.coffee'
            'coffee/services/*.coffee'
            'coffee/directives/*.coffee'
            'coffee/controllers/*.coffee'
          ]
    coffeelint:
      app: [
        'coffee/**/*.coffee'
      ]
    wiredep:
      task:
        src: [
          'index.html'
        ]
        options: {}
    injector:
      options: {}
      # Inject application script files into index.html (doesn't include bower)
      scripts:
        options:
          transform: (filePath) ->
            filePath = filePath.replace(/^\//, '')
            "<script src='#{filePath}'></script>"
          starttag: '<!-- app:js -->',
          endtag: '<!-- endapp -->'
        files:
          'index.html': [
            'app.js'
          ]
      css:
        options:
          transform: (filePath) ->
            filePath = filePath.replace(/^\//, '')
            "<link rel='stylesheet' href='#{filePath}'>"
          starttag: '<!-- app:css -->',
          endtag: '<!-- endapp -->',
        files:
          'index.html': [
            'main.css'
          ]
    watch:
      html:
        files: 'index.html'
        tasks: 'htmlhint'
      sass:
        files: '*.scss'
        tasks: [
          'sass'
          #'injector:css'
        ]
      coffee:
        files: 'coffee/**/*.coffee'
        tasks: [
          'coffeelint'
          'coffee'
          #'injector:scripts'
        ]
  grunt.loadNpmTasks 'grunt-injector'
  grunt.loadNpmTasks 'grunt-wiredep'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-htmlhint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.registerTask 'build', ['htmlhint','sass','coffeelint','coffee', 'injector']
  grunt.registerTask 'dist', ['build', 'compress']
  grunt.registerTask 'default', ['build','watch']
