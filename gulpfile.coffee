###*
 * Development tasks
 *
 * @author  Christopher Pappas & Matthew Fordham
 * @date    6.4.14
 *
 * Primary Tasks:
 *    gulp dev   : Development mode, file-watcher
 *    gulp build : Minify all sources and deploy for distribution
 *
###

gulp         = require 'gulp'
autoprefixer = require 'gulp-autoprefixer'
bowerFiles   = require 'gulp-bower-files'
browserify   = require 'gulp-browserify'
coffeeify    = require 'coffeeify'
concat       = require 'gulp-concat'
connect      = require 'gulp-connect'
clean        = require 'gulp-clean'
imagemin     = require 'gulp-imagemin'
livereload   = require 'gulp-livereload'
minifyCSS    = require 'gulp-minify-css'
mocha        = require 'gulp-mocha'
mochaPhantom = require 'gulp-mocha-phantomjs'
notify       = require 'gulp-notify'
rename       = require 'gulp-rename'
stylus       = require 'gulp-stylus'
uglify       = require 'gulp-uglify'




# --------------------------------------------------------
# Path Configurations
# --------------------------------------------------------


# Root application path
basePath = '.'

# Directory where source files live
sources = "#{basePath}/src"

# Path to compile to during development
output =  "#{basePath}/public"

# Path to build final deploy files
dist =    "#{basePath}/dist"

# Test specs directory and html
test =    "#{basePath}/test"

# Directory where vendor files live
vendor =  "#{sources}/vendor"

# Browser port during development
port = 3000




#--------------------------------------------------------
# Copy Bower libraries to vendor directory
#--------------------------------------------------------


gulp.task "bower", ->
   bowerFiles()
      .pipe gulp.dest "#{vendor}"




#--------------------------------------------------------
# Compile scripts using Browserify
#--------------------------------------------------------


gulp.task "browserify-dev", ->
   gulp.src "#{sources}/scripts/app.coffee", read: false
      .pipe browserify
         transform:  ["coffeeify"]
         extensions: [".coffee", ".js"]

      .pipe rename "app.js"
      .pipe gulp.dest "#{output}/assets/scripts"



gulp.task "browserify-test", ->
   gulp.src "#{test}/spec-runner.coffee", read: false
      .pipe browserify
         transform:  ["coffeeify"]
         extensions: [".coffee", ".js"]

      .pipe rename "app.spec.js"
      .pipe gulp.dest "#{test}/html/spec/"




# --------------------------------------------------------
# Clean working development directory
# --------------------------------------------------------


gulp.task "clean-dev", ->
   gulp.src "#{output}/assets", read: false
      .pipe clean()

gulp.task "clean-dist", ->
   gulp.src "#{dist}", read: false
      .pipe clean()





# --------------------------------------------------------
# Concatinate vendor files
# --------------------------------------------------------


gulp.task "concat", ->
   vendorFiles = [
      "lodash/dist/lodash.compat.js"
      "jquery/jquery.js"
      "backbone/backbone.js"
      "greensock/src/uncompressed/TweenMax.js"

   ].map (file) -> "#{vendor}/" + file

   gulp.src vendorFiles
      .pipe concat "vendor.js"
      .pipe gulp.dest "#{output}/assets/scripts/"





# --------------------------------------------------------
# Connect to server
# --------------------------------------------------------


gulp.task "connect", ->
   connect.server
      host: null
      port: "#{port}"
      root: "#{public}"
      livereload: true




# --------------------------------------------------------
# Copy source files
# --------------------------------------------------------

# Copy assets
gulp.task "copy-assets", ->
   gulp.src "#{sources}/assets/**/*.*"
      .pipe gulp.dest "#{output}/assets"

# Copy html
gulp.task "copy-html", ->
   gulp.src "#{sources}/html/**/*.*"
      .pipe gulp.dest "#{output}"

# Copy dist files
gulp.task "copy-dist", ->
   gulp.src "#{output}"
      .pipe gulp.dest "#{dist}"




#--------------------------------------------------------
# Optimize images using ImageMin
#--------------------------------------------------------


gulp.task "imagemin", ->
   gulp.src "#{output}/assets/images/*"
      .pipe imagemin
         optimizationLevel: 5

      .pipe gulp.dest "#{output}/assets/images"




#--------------------------------------------------------
# Minify sources and vendor
#--------------------------------------------------------


gulp.task "minify", ->

   # Uglify sources
   gulp.src "#{output}/assets/scripts/app.js", ->
      .pipe uglify()
      .pipe gulp.dest "#{output}/assets/scripts/"

   # Uglify vendor
   gulp.src "#{output}/assets/scripts/vendor.js", ->
      .pipe uglify()
      .pipe gulp.dest "#{output}/assets/scripts/"

   # Minify CSS
   gulp.src "#{output}/assets/styles/app.css", ->
      .pipe minifyCSS()
      .pipe gulp.dest "#{output}/assets/styles/app.css"




#--------------------------------------------------------
# Mocha tests via PhantomJS or the browser
#--------------------------------------------------------


gulp.task "test", ->
   gulp.start "browserify-dev", "browserify-test", "concat"

   gulp.src "#{test}/html/index.html"
      .pipe mochaPhantom
         reporter: 'Spec'




#--------------------------------------------------------
# Compile Stylus stylesheet files
#--------------------------------------------------------


gulp.task "stylus", ->
   gulp.src "#{sources}/styles/main.styl"
      .pipe stylus()
      .pipe autoprefixer()
      .pipe gulp.dest "#{output}/assets/styles"




#--------------------------------------------------------
# Watch for changes and reload page
#--------------------------------------------------------


gulp.task "watch", ->
   server = livereload()

   gulp.watch "#{sources}/assets/**/*.*",             [ "copy-assets" ]
   gulp.watch "#{sources}/html/**/*.*",               [ "copy-html" ]
   gulp.watch "#{sources}/scripts/**/*.{coffee,js}",  [ "browserify-dev" ]
   gulp.watch "#{sources}/styles/**/*.{styl,css}",    [ "stylus" ]
   gulp.watch "#{test}/**",                           [ "test" ]
   gulp.watch "#{sources}/vendor/**/*.*",             [ "concat" ]

   # LiveReload
   gulp.watch(["#{output}/**"]).on "change", (file) ->
      server.changed file.path




# + ----------------------------------------------------------

gulp.task "default", ["dev"]

gulp.task "dev", [
   "clean-dev"
   "copy-assets"
   "copy-html"
   "bower"
   "browserify-dev"
   "stylus"
   "bower"
   "concat"
   "test"
   "connect"
   "watch"
]

gulp.task "build", [
   "clean-dev"
   "clean-dist"
   "copy-assets"
   "copy-html"
   "bower"
   "browserify-dev"
   "stylus"
   "bower"
   "concat"
   "test"
   "minify"
   "copy-dist"
]
