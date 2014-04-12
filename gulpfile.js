var gulp = require('gulp'),
    log = require('gulp-util').log,
    rename = require('gulp-rename'),
    flatten = require('gulp-flatten'),  
    coffee = require('gulp-coffee'),
    uglify = require('gulp-uglify'),
    compass = require('gulp-compass'),
    minifyCSS = require('gulp-minify-css'),
    concat = require('gulp-concat');

gulp.task('toMinJS', function() {
    gulp.src('./src/scripts/*.coffee')
        .pipe(coffee({bare: true}).on('error', log))
        .pipe(concat('twitterfontana.min.js'))
        .pipe(uglify())        
        .pipe(gulp.dest('./dist'))          
});
gulp.task('toMinCSS', function() {
    gulp.src('./src/styles/*.scss')
        .pipe(compass({
        	sass: 'src/styles',
        	require: 'animate'
        }))
        .on('error', log)
        .pipe(concat('transitions.min.css'))
        .pipe(minifyCSS())        
        .pipe(gulp.dest('./dist'))          
});
/*
gulp.task('toJS', function() {
    gulp.src('./src/*.coffee')
        .pipe(coffee({bare: true}).on('error', log))
        .pipe(gulp.dest('./dist'))          
});

gulp.task('exampleScripts', function() {
	gulp.src('./example/scripts.coffee')
	    .pipe(coffee())
	    .pipe(gulp.dest('./example'))
});
*/
gulp.task('lib', function() {
    gulp.src('bower_components/**/*.min.*')
        .pipe(flatten())
        .pipe(gulp.dest('./example/lib'))
});
gulp.task('watch', function() {
    log('Watching files');
    gulp.watch('./src/**/*', ['build']);
});

//define cmd line default task
gulp.task('build', ['toMinJS', 'toMinCSS']);
gulp.task('default', ['build', 'watch']);