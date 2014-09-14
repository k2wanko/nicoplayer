
gulp = require 'gulp'
gutil = require 'gulp-util'
gulpif = require 'gulp-if'

plumber = require 'gulp-plumber'
notify = require 'gulp-notify'

yaml = require 'gulp-yaml'

browserify = require 'gulp-browserify'
rename = require 'gulp-rename'
sourcemaps = require 'gulp-sourcemaps'
uglify = require 'gulp-uglify'

jade = require 'gulp-jade'

stylus = require 'gulp-stylus'

zip = require 'gulp-zip'

bower = require 'gulp-bower'

clean = require 'gulp-clean'

errorNotify = (msg = "Error: <%= error.message %>")->
  plumber errorHandler: notify.onError msg
  
gulp.task 'default', ['manifest', 'locales', 'bower', 'coffee', 'jade', 'stylus']

gulp.task 'watch', ['default'], ->
  gulp.watch 'src/manifest.yml', ['manifest']
  gulp.watch 'src/_locales/**/*.yml', ['locales']
  gulp.watch 'src/*.coffee', ['coffee']
  gulp.watch 'src/*.jade', ['jade']
  gulp.watch 'src/*.styl', ['stylus']

gulp.task 'clean', ->
  gulp.src ['app/*', '!app/assets/']
  .pipe clean force: true

gulp.task 'manifest', ->
  gulp.src 'src/manifest.yml'
  .pipe errorNotify()
  .pipe yaml().on( 'manifest:error', gutil.log )
  .pipe gulp.dest 'app/'

gulp.task 'bower', ->
  bower()

gulp.task 'locales', ->
  gulp.src 'src/_locales/**/*.yml'
  .pipe errorNotify()
  .pipe yaml().on( 'manifest:error', gutil.log )
  .pipe gulp.dest 'app/_locales/'

gulp.task 'coffee', ->
  gulp.src 'src/*.coffee', read: false
  .pipe errorNotify()
  .pipe browserify
    transform: ['coffeeify']
    extensions: (ext for ext of require.extensions)
  .pipe rename (path)-> path.extname = '.js'; path
  .pipe gulpif !(DEBUG = true), uglify()
  .pipe gulp.dest 'app/'
    
gulp.task 'jade', ->
  gulp.src 'src/*.jade'
  .pipe errorNotify()
  .pipe jade()
  .pipe gulp.dest 'app/'
    
gulp.task 'stylus', ->
  gulp.src 'src/*.styl'
  .pipe errorNotify()
  .pipe stylus()
  .pipe gulp.dest 'app/'

gulp.task 'package', ['default'], ->
  gulp.src 'app/*'
  .pipe errorNotify()
  .pipe zip 'package.zip'
  .pipe gulp.dest './'
