#--------------------------------------------------------
# Requirements
#--------------------------------------------------------

gulp   = require 'gulp'
jade   = require 'gulp-jade'
config = require "../config.coffee"

#--------------------------------------------------------
# Compile Jade
#--------------------------------------------------------

gulp.task 'markup', ->
  gulp.src './source/*.jade'
    .pipe jade pretty: true
    .pipe gulp.dest "#{config.publicPath}"


