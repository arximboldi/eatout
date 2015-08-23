# Load plugins
gulp = require 'gulp'
sass = require 'gulp-sass'
sourcemaps = require 'gulp-sourcemaps'
minifycss = require 'gulp-minify-css'
jshint = require 'gulp-jshint'
uglify = require 'gulp-uglify'
imageResize = require 'gulp-image-resize'
rename = require 'gulp-rename'
clean = require 'gulp-clean'
concat = require 'gulp-concat'
notify = require 'gulp-notify'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
gutil = require 'gulp-util'
yaml = require 'gulp-yaml'
jsoncombine = require 'gulp-jsoncombine'
_ = require 'underscore'
path = require 'path'
marked = require 'marked'
print = require 'gulp-print' # prints names of files to the console

sources =
    sass:    'style/stylesheets/**/*.scss'
    css:     'style/stylesheets/style.scss'
    html:    'index.html'
    coffee:  'src/coffee/**/*.coffee'
    js:      'src/**/*.js'
    libs:    [
             'lib/bower/**/*min.js'
             'lib/js-marker-clusterer/**/*_compiled.js'
             'src/js/facebook.js'
             'src/js/analytics.js'
             ]
    images:  'style/images/places/**/*.{JPG,jpg}'
    yaml:    'data/**/*.yaml'

dest =
    coffee: 'src/coffee'
    sass:   'style/stylesheets'
    css:    'dist/styles'
    html:   'dist/'
    js:     'dist/js'
    images: 'dist/images'
    json:   'data'


# Sass -dev
gulp.task 'sass', ->
    gulp.src(sources.sass)
        .pipe(sourcemaps.init())
        .pipe(sass({errLogToConsole: true}))
        .pipe(sourcemaps.write('.'))
        .pipe(gulp.dest(dest.sass))

# Styles -dist
gulp.task 'styles', ->
    gulp.src(sources.css)
        .pipe(sass({errLogToConsole: true}))
        .pipe(rename(suffix: '.min'))
        .pipe(minifycss({processImport: true}))
        .pipe(gulp.dest(dest.css))
        .pipe(notify(message: 'Styles task complete'))

# Coffee -dev
gulp.task 'coffee', ->
    gulp.src(sources.coffee)
        .pipe(sourcemaps.init())
        .pipe(coffee({bare: true}).on('error', gutil.log))
        .pipe(sourcemaps.write('.'))
        .pipe(gulp.dest(dest.coffee))

# Scripts -dist
gulp.task 'scripts', ->
    gulp.src(sources.coffee)
        .pipe(coffee({bare: true}).on('error', gutil.log))
        .pipe(concat('app.js'))
        .pipe(gulp.dest(dest.js))
        .pipe(rename(suffix: '.min'))
        .pipe(uglify())
        .pipe(gulp.dest(dest.js))

# Scripts -dist
gulp.task 'libs', ->
    gulp.src(sources.libs)
    .pipe(print())
    .pipe(concat('libs.min.js'))
    .pipe(gulp.dest(dest.js))

# Coffee lint
gulp.task 'lint', ->
    gulp.src(sources.coffee)
        .pipe(coffeelint())
        .pipe(coffeelint.reporter())

# JS lint
gulp.task 'jslint', ->
    gulp.src(sources.js)
        .pipe(jshint('.jshintrc'))
        .pipe(jshint.reporter('jshint-stylish'))

# Images -resize
gulp.task 'resize', ->
    gulp.src(sources.images)
        .pipe imageResize
            width : 1000
            upscale : false
        .pipe(gulp.dest((file) ->
            file.base.replace('places', 'places-M')
        )) # Destination in the same folder as source

# Convert json to
gulp.task 'data', ->
    gulp.src(sources.yaml)
        .pipe yaml()
        .pipe jsoncombine 'places.json',
            ((data) ->
                result = _.pairs data
                    .map ([fname, obj]) ->
                        _.extend obj,
                            slug: path.basename path.dirname fname
                            description: marked obj.description
                new Buffer JSON.stringify result),
        .pipe gulp.dest dest.json

# Watch
gulp.task 'watch', ->
    gulp.watch sources.sass, ['sass']
    gulp.watch sources.coffee, ['coffee']

# Clean
gulp.task 'clean', ->
    gulp.src([dest.js, dest.css], {read: false})
        .pipe clean()

gulp.task 'dev', ['coffee', 'data', 'sass'], ->

# Default task
gulp.task 'default', ['clean'], ->
    gulp.start 'styles', 'scripts', 'libs'
