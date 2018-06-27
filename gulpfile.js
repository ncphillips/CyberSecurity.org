
/**
 *   1. Required Node Packages
 *   2. Theme/Paths Variables
 *   3. Styles
 *   4. Scripts
 *   5. Images
 *   6. Fonts
 *   7. HTML
 *   8. Jekyll
 *   9. Major Build/Watch/Server Commands
 *   10. Misc.
 */



// -----------------------------------------------------------------------------
//   1: Required Node Plugins
// -----------------------------------------------------------------------------

const $              = require('gulp-load-plugins')();
const argv           = require('yargs').argv;
const autoprefixer   = require('autoprefixer');
const bourbon        = require("bourbon").includePaths;
const browserSync    = require('browser-sync').create();
const del            = require('del');
const fs             = require('fs');
const glob           = require('glob');
const gulp           = require('gulp');
const jpegRecompress = require('imagemin-jpeg-recompress');
const neat           = require("bourbon-neat").includePaths;
const order          = require('postcss-ordered-values');
const runSequence    = require('run-sequence');
const pkg            = require('./package.json');
const psi            = require('psi');
const url            = require('url');
const userHome       = require('user-home');



// -----------------------------------------------------------------------------
//   2: Paths Variables
// -----------------------------------------------------------------------------

let is_dev               = (argv.d || argv.dev || argv.development) ? true : false;
let is_test              = (argv.t || argv.test) ? true : false;
let site                 = (argv.site) ? argv.site : pkg.site;
const _npm_dir           = './node_modules'
const _assets_dir        = './assets';
const _build_dir         = './_site';
const _build_assets_dir  = _build_dir + '/assets';
const _build_img_dir     = _build_assets_dir + '/img';
const _build_media_dir   = _build_assets_dir + '/media';
const _build_js_dir      = _build_assets_dir + '/js';
const _build_font_dir    = _build_assets_dir + '/fonts';
const _build_css_dir     = _build_assets_dir + '/css';


// -----------------------------------------------------------------------------
//   3: Styles
// -----------------------------------------------------------------------------

/**
 * Task: build:styles:main
 * Uses Sass compiler to process styles, adds vendor prefixes, minifies, then
 * outputs file to the appropriate location.
 */
gulp.task('build:styles:main', () => {

  return $.rubySass(_assets_dir + '/styles/styles.scss', {
      sourcemap: is_dev,
      style: is_dev ? 'expanded' : 'compressed',
      trace: true,
      loadPath: [bourbon, neat]
    })
    .pipe(
      $.postcss(
        [
          autoprefixer({ browsers: ['last 3 versions'], cascade: false }),
          order()
        ]
      )
    )
    .pipe(!is_dev ? $.cleanCss() : $.util.noop())
    .pipe(is_dev ? $.sourcemaps.write() : $.util.noop())
    .pipe($.size({title: 'Styles: Main', showFiles: is_dev}))
    .pipe(gulp.dest(_build_css_dir))
    .pipe(browserSync.stream())
    .on('error', $.util.log);

});


/**
 * Task: build:styles:embed
 * Processes CSS for embed usage.
 */
gulp.task('build:styles:embed', () => {

  return $.rubySass(_assets_dir + '/styles/**/embed-*.scss', {
      sourcemap: is_dev,
      style: is_dev ? 'expanded' : 'compressed',
      trace: true,
      loadPath: [bourbon, neat]
    })
    .pipe(
      $.postcss(
        [
          autoprefixer({ browsers: ['last 3 versions'], cascade: false }),
          order()
        ]
      )
    )
    .pipe(!is_dev ? $.cleanCss() : $.util.noop())
    .pipe(is_dev ? $.sourcemaps.write() : $.util.noop())
    .pipe($.rename((path) => { path.dirname = ""; }))
    .pipe($.size({title: 'Styles: Embeds', showFiles: is_dev}))
    .pipe(gulp.dest(_build_css_dir))
    .on('error', $.util.log);

});


/**
 * Task: build:styles:standalone
 * Copies any other CSS files to the assets directory, to be used by pages/posts
 * that specify custom CSS files.
 */
gulp.task('build:styles:standalone', () => {

  return gulp.src(_assets_dir + '/styles/standalone/*.css')
    .pipe(!is_dev ? $.cleanCss() : $.util.noop())
    .pipe($.size({title: 'Styles: Standalone', showFiles: is_dev}))
    .pipe(gulp.dest(_build_css_dir))
    .pipe(browserSync.stream())
    .on('error', $.util.log);

});


/**
 * Task: build:styles
 * Builds all site styles.
 */
gulp.task('build:styles', [
  'build:styles:embed',
  'build:styles:main',
  'build:styles:standalone'
]);


/**
 * Task: watch:styles
 * Watch for style changes, build then reload BrowserSync.
 * Only necessary for style embeds in Jekyll.
 */
gulp.task('watch:styles', (callback) => {

  runSequence(
    'build:styles:embed',
    'watch:jekyll',
    callback
  )

});


/**
 * Task: clean:styles
 * Deletes all processed site styles.
 */
gulp.task('clean:styles', (callback) => {

  del.sync(_build_css_dir);
  callback();

});



// -----------------------------------------------------------------------------
//   4: Scripts
// -----------------------------------------------------------------------------

/**
 * Task: build:scripts:main
 * Main site scripts; concatenates and uglifies global JS files and outputs
 * result to the appropriate location for appropriate environments.
 */
gulp.task('build:scripts:main', () => {

  const dirs = glob.sync(_assets_dir + '/js/*');

  if (!dirs.length) {
    return;
  }

  dirs.forEach((dir) => {

    dir = dir.split('/js/')[1];

    // Exclude Standalone
    if (dir === 'standalone') {
      return;
    }

    let scripts = [
      _assets_dir + '/js/' + dir + '/libs/**/*.js',
      _assets_dir + '/js/' + dir + '/**/*.js'
    ];

    // Add any JS from NPM dependancies to this footer_libs.
    // eg: _npm_dir + '/responsive-nav/responsive-nav.min.js',
    if (dir === 'footer') {
      scripts = [
        _npm_dir + '/jquery/dist/jquery.min.js',
        _npm_dir + '/waypoints/lib/jquery.waypoints.min.js',
      ].concat(scripts);
    }

    if (dir === 'header') {
      scripts = [
        // _npm_dir + '/jquery/dist/jquery.min.js',
      ].concat(scripts);
    }

    /* Include additional dependency JS to your created folders. e.g.
    if (dir === 'JSFOLDER') {
      scripts = [].concat(scripts);
    }
    */

    return gulp.src(scripts)
      .pipe(is_dev ? $.sourcemaps.init() : $.util.noop())
      .pipe($.concat(dir + '.js'))
      .pipe($.babel())
      .pipe(is_dev ? $.util.noop() : $.uglify({preserveComments: 'some'}))
      .pipe(is_dev ? $.sourcemaps.write() : $.util.noop())
      .pipe($.size({title: 'Scripts: Main', showFiles: is_dev}))
      .pipe(gulp.dest(_build_js_dir))
      .on('error', $.util.log);

  });

});


/**
 * Task: build:scripts:standalone
 * For vendor or plain scripts, add to the `_assets/js/standalone` directory.
 * This copies scripts to the build directory for usage.
 */
gulp.task('build:scripts:standalone', () => {

    return gulp.src(_assets_dir + '/js/standalone/*.js')
      .pipe(is_dev ? $.sourcemaps.init() : $.util.noop())
      .pipe(is_dev ? $.util.noop() : $.uglify({preserveComments: 'some'}))
      .pipe(is_dev ? $.sourcemaps.write() : $.util.noop())
      .pipe($.size({title: 'Scripts: Standalone', showFiles: is_dev}))
      .pipe(gulp.dest(_build_js_dir))
      .on('error', $.util.log);

});


/**
 * Task: lint:scripts
 * Lint JavaScript
 */
gulp.task('lint:scripts', () => {

  if (!is_dev) {
    return;
  }

  return gulp.src([
      _assets_dir + '/js/**/*.js',
      '!' + _npm_dir + '/**'
    ])
    .pipe($.eslint())
    .pipe($.eslint.format())
    .on('error', $.util.log);

});


/**
 * Task: lint:scripts:fix
 * Fix JavaScript Lint Warnings/Errors
 */
gulp.task('lint:scripts:fix', () => {

  return gulp.src([
      _assets_dir + '/js/**/*.js',
      '!' + _assets_dir + '/js/standalone/*.js',
      '!' + _npm_dir + '/**'
    ])
    .pipe($.eslint({fix:true}))
    .pipe($.eslint.format())
    .pipe(gulp.dest((file) => file.base))
    .on('error', $.util.log);

});


/**
 * Task: build:scripts
 * Concatenates and uglifies global JS files and outputs result to the
 * appropriate location.
 */
gulp.task('build:scripts', (callback) => {

  runSequence(
    'lint:scripts',
    ['build:scripts:main', 'build:scripts:standalone'],
    callback
  )

});



/**
 * Task: watch:scripts
 * Watch for JS changes, build then reload BrowserSync.
 */
gulp.task('watch:scripts', (callback) => {

  runSequence(
    'build:scripts',
    'reload',
    callback
  )

});


/**
 * Task: clean:scripts
 * Deletes all processed scripts.
 */
gulp.task('clean:scripts', (callback) => {

  del.sync(_build_js_dir);
  callback();

});



// -----------------------------------------------------------------------------
//   5: Images
// -----------------------------------------------------------------------------

/**
 * Task: build:images:site
 * Copies image files.
 */
gulp.task('build:images:site', () => {

  return gulp.src(_assets_dir + '/img/**/*.{png,jpg,jpeg,gif,svg,ico}')
    .pipe($.changed(_build_img_dir))
    .pipe($.size({title: 'Images: Site', showFiles: is_dev}))
    .pipe(gulp.dest(_build_img_dir));

});


/**
 * Task: build:images:media
 * Copies image files.
 */
gulp.task('build:images:media', () => {

  return gulp.src(_assets_dir + '/media/**/*.{png,jpg,jpeg,gif,svg,pdf,zip,eps,ico}')
    .pipe($.changed(_build_media_dir))
    .pipe($.size({title: 'Images: Media', showFiles: is_dev}))
    .pipe(gulp.dest(_build_media_dir));

});


/**
 * Task: optimize:images
 * Optimizes image files.
 */
gulp.task('optimize:images', () => {

  return gulp.src([
    _build_img_dir + '/**/*.{png,jpg,jpeg,gif,svg,ico}',
    _build_media_dir + '/**/*.{png,jpg,jpeg,gif,svg,pdf,zip,eps,ico}'
    ])
    .pipe(
      $.cache(
        $.imagemin([
          $.imagemin.gifsicle({interlaced: true}),
          jpegRecompress({progressive: true}),
          $.imagemin.optipng({optimizationLevel: 3}),
          $.imagemin.svgo({
            plugins: [
              {
                convertStyleToAttrs: true,
                convertColors: true,
                minifyStyles: true,
                removeUselessDefs: true,
                removeViewBox: false,
                removeHiddenElems: false
              }
            ]
          })
        ])
      )
    )
    .pipe($.size({title: 'Assets', showFiles: is_dev}))
    .pipe(gulp.dest((file) => file.base));

});


/**
 * Task: build:images
 * Builds all site images.
 */
gulp.task('build:images', (callback) => {

  runSequence(
    ['build:images:site', 'build:images:media'],
    'optimize:images',
    callback
  )

});


/**
 * Task: watch:images
 * Watch images changes, then reloads browser.
 */
gulp.task('watch:images', (callback) => {

  runSequence(
    'build:images',
    'watch:jekyll',
    callback
  )

});



/**
 * Task: clean:images
 * Deletes all processed images.
 */
gulp.task('clean:images', (callback) => {

  del.sync([_build_img_dir, _build_media_dir]);
  callback();

});



// -----------------------------------------------------------------------------
//   6: Fonts
// -----------------------------------------------------------------------------

/**
 * Task: build:fonts
 * Copies fonts.
 */
gulp.task('build:fonts', () => {

  return gulp.src(_assets_dir + '/fonts/**.*')
    .pipe($.rename((path) => { path.dirname = ''; }))
    .pipe($.size({title: 'Fonts', showFiles: is_dev}))
    .pipe(gulp.dest(_build_font_dir))
    .on('error', $.util.log);

});


/**
 * Task: watch:fonts
 * Watch for font changes, build then reload BrowserSync.
 */
gulp.task('watch:fonts', (callback) => {

  runSequence(
    'build:fonts',
    'reload',
    callback
  )

});


/**
 * Task: clean:fonts
 * Deletes all processed fonts.
 */
gulp.task('clean:fonts', (callback) => {

  del.sync([_build_font_dir]);
  callback();

});



// -----------------------------------------------------------------------------
//   7: HTML
// -----------------------------------------------------------------------------

/**
 * Task: build:html
 * Runs the HTML build command that minifies code in Testing/Production Environments.
 */
gulp.task('build:html', () => {

  if (is_dev) {
    return;
  }

  return gulp.src([
    _build_dir + '/**/*.html',
    '!' + _build_dir + '/admin/**/*.html'
    ])
    .pipe($.htmlmin({
      removeComments: true,
      collapseWhitespace: true,
      collapseBooleanAttributes: true,
      removeAttributeQuotes: true,
      removeRedundantAttributes: true,
      removeEmptyAttributes: true,
      removeScriptTypeAttributes: true,
      removeStyleLinkTypeAttributes: true,
      removeOptionalTags: true
    }))
    .pipe($.size({title: 'HTML', showFiles: is_dev}))
    .pipe(gulp.dest(_build_dir))
    .on('error', $.util.log);

});



// -----------------------------------------------------------------------------
//   8: Jekyll
// -----------------------------------------------------------------------------

/**
 * Task: build:jekyll
 * Runs the jekyll build command.
 */
gulp.task('build:jekyll', () => {

  let command = '';

  if (is_dev) {
    command = 'bundle exec jekyll build --quiet --future --config _config.yml,_config.dev.yml';
  } else if(is_test) {
    command = 'JEKYLL_ENV=testing bundle exec jekyll build --config _config.yml,_config.test.yml';
  } else {
     command = 'JEKYLL_ENV=production bundle exec jekyll build --config _config.yml'
  }

  return gulp.src('')
    .pipe($.run(command))
    .on('error', $.util.log);

});


/**
 * Task: jekyll:check
 * Special task for checking your Jekyll Setup.
 */
gulp.task('jekyll:check', () => {

  let command = '';

  if (is_dev) {
    command = 'bundle exec jekyll doctor --config _config.yml,_config.dev.yml';
  } else if(is_test) {
    command = 'bundle exec jekyll doctor --config _config.yml,_config.test.yml';
  } else {
     command = 'bundle exec jekyll doctor'
  }

  return gulp.src('')
    .pipe($.run(command))
    .on('error', $.util.log);

});


/**
 * Task: watch:jekyll
 * Special task for building the site then reloading via BrowserSync.
 */
gulp.task('watch:jekyll', (callback) => {

  runSequence(
    'build:jekyll',
    'build:html',
    'reload',
    callback
  );

});



// -----------------------------------------------------------------------------
//   9: Major Build/Watch/Clean Commands
// -----------------------------------------------------------------------------

/**
 * Task: build
 * Clean and rebuild site.
 */
gulp.task('build', (callback) => {

  runSequence(
    'clean',
    'build:images',
    'build:fonts',
    'build:scripts',
    'build:styles',
    'build:jekyll',
    'build:html',
    callback
  );

});
gulp.task('default', ['build']); // Bind Default to build.


/**
 * Task: serve
 * Static Server + watching files.
 * Only rebuild site if --rebuild option is passed to serve command.
 */
gulp.task('serve', () => {

  // Convert to development, if not already flagged.
  is_dev = !is_test ? true : false;

  if (argv.rebuild !== undefined) {
    runSequence('build', 'watch');
    return;
  }

  runSequence('watch');

});


/**
 * Task: Watch
 *
 */
gulp.task('watch', () => {

  // Convert to development, if not already flagged.
  is_dev = !is_test ? true : false;

  // Browser Sync.
  browserSync.init({
    server: {
      baseDir: _build_dir,
      serveStaticOptions: {
        extensions: ['html']
      },
      middleware: (req, res, next) => {

        const path = url.parse(req.url).pathname;

        // If anything but vanity url, run as normal.
        if (path.indexOf('.') > -1 || path === "/") {
          return next();
        }

        // Ends with Trailing Slash subtract it, then add .html
        // const file = path.endsWith('/') ? path.substring(0, path.length - 1) + '.html' : path + '.html';
        const file = path.endsWith('/') ? path + 'index.html' : path + '/index.html';

        // 404 if page doesn't exists
        if (!fs.existsSync(_build_dir + file) && file.indexOf("browser-sync-client") < 0) {
          req.url = '/404.html';
        } else {
          req.url = file;
        }

        return next();
      }
    },
    https: {
        key: userHome + "/.localhost-ssl/localhost.key",
        cert: userHome + "/.localhost-ssl/localhost.crt"
    },
    ghostMode: false,
    port: 4000,
    logFileChanges: true,
    logLevel: 'info',
    open: true
  });

  // Watch .scss files; changes are piped to browserSync.
  gulp.watch([_assets_dir + '/styles/**/*', '!' + _assets_dir + '/styles/**/embed-*'], ['build:styles']);

  // Watch embed .scss styles to rebuild css embeds in Jekyll
  gulp.watch(_assets_dir + '/styles/**/embed-*', ['watch:styles']);

  // Watch image files; relaod browserSync.
  gulp.watch(_assets_dir + '/img/**/*', ['watch:images']);

  // Watch font files; relaod browserSync.
  gulp.watch(_assets_dir + '/fonts/**/*', ['watch:fonts']);

  // Watch scripts files
  gulp.watch(_assets_dir + '/js/**/*.js', ['watch:scripts']);

  // Watch: Jekyll Configuration, Favicon, Feeds, JS, Data, Collections, HTML, Ruby Plugins.
  gulp.watch([
      '_config*.yml',
      '**.xml',
      '_data/**.*+(yml|yaml|csv|json)',
      '_*/**/*.+(html|md|markdown|MD)',
      'html/**/*.+(html|md|markdown|MD|block|tag|snippet)',
      'plugins/**/*.rb',
      'robots.txt',
      '!_site/**/*.*',
    ],
    ['watch:jekyll']
  );

  // Watch drafts if --drafts flag was passed.
  if (module.exports.drafts) {
    gulp.watch('_drafts/*.+(md|markdown|MD)', ['watch:jekyll']);
  }

});


/**
 * Task: reload
 * Reloading via BrowserSync.
 */
gulp.task('reload', (callback) => {

  browserSync.reload();
  callback();

});


/**
 * Task: clean
 * Deletes the entire _site directory.
 */
gulp.task('clean', (callback) => {

  del.sync(_build_dir);
  callback();

});



// -----------------------------------------------------------------------------
//   10: Misc.
// -----------------------------------------------------------------------------

/**
 * Task: update:gems
 * Updates Ruby gems.
 */
gulp.task('update:gems', () => {

  return gulp.src('')
    .pipe($.run('bundle install'))
    .pipe($.run('bundle update'))
    .pipe($.notify({ message: 'Bundle Update Complete' }))
    .on('error', $.util.log);

});


/**
 * Task: cache:clear
 * Clears the gulp cache. Currently this just holds processed images.
 */
gulp.task('cache:clear', (done) => {

  return $.cache.clearAll(done);

});


/**
 * Task: pagespeed
 * Run PageSpeed Insights for Mobile & Desktop. Custom site urls: --site=https://www.example.com
 */
gulp.task('pagespeed', () => {

  if (!site) {
    return;
  }

  // Mobile Strategy
  psi.output(site, {
    nokey: 'true',
    strategy: 'mobile',
  });

  // Destkop Strategy
  psi.output(site, {
    nokey: 'true',
    strategy: 'desktop',
  });

});
