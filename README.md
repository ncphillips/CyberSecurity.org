# [[DOMAIN]]([PROTOCOL][URL])

> Powered by [Netlify](https://www.netlify.com/) & [Jekyll](https://jekyllrb.com/)


## Initial Setup

***

### Search & Replace

Be sure to exclude the trailing slash('/') from the urls when replacing. Remove this `Search & Replace` section when completed.

```
[DOMAIN] = e.g. BusinessAnalytics.com
[URL] = e.g. www.businessanalytics.com
[BRANDEDURL] = e.g. forms.businessanalytics.com
[PROTOCOL] = e.g. https://
[REPOURL] = e.g. https://github.com/HigherEducation/BusinessAnalytics.com
```

***

### Install Dependencies

Prerequisites you will need:

* [npm](https://docs.npmjs.com/getting-started/installing-node)
* [Bundler](http://bundler.io/)
* [gulp](https://gulpjs.com/)

You can then use **npm** to install **gulp**:

1.  Install **gulp** globally: `npm i -g gulp-cli`
    * _(If you have previously installed a version of gulp globally, please run `npm rm --global gulp` to make sure your old version doesn't collide with gulp-cli.)_
2.  Install gulp in your project devDependencies: `npm i --save-dev gulp`
3.  Run **npm**: `npm install`
4.  Run **Bundler**: `bundler install`
5.  Follow the instructions here to [create a Self-Signed SSL Certificate](<https://github.com/HigherEducation/Frontend/wiki/BrowserSync(localhost)---Self-Signed-Certificate>)


## Builds

### Production Build

* Branch: Master
* Config: config.yml
* Jekyll Environment: `production`
* Command: `gulp build`
* Minification: HTML, CSS, JS, etc
* Sourcemaps: None

### Test Build

* Config: config.yml -> config.test.yml
* Jekyll Environment: `testing`
* Command: `gulp build --t or --test`
* Minification: HTML, CSS, JS, etc
* Sourcemaps: None

Build mimicks the Production Build except for using Netlify URLs. Used for Pull Request Previews(Deploy Previews) staging environments before merging into Production.

### Development Build

* Config: config.yml -> config.dev.yml
* Jekyll Environment: `development`
* Command: `gulp build --d or --dev or --development`
* Minification: None
* Sourcemaps: CSS, JS

Build is used for local development and branch deploys for the staging environments.


### Gulp Commands

#### Flags

##### `--d or --dev or --development`

###### Development Build

```
HTML: Standard
Styles: Expanded with Inline Sourcemaps, Order Properties, Autoprefixer.
JS: Expanded with Inline Sourcemaps, ES2015.
Images: Optimized
```

##### `--t or --test`

###### Test Build

```
HTML: Minified
Styles: Compressed with no Sourcemaps, Order Properties, Autoprefixer, CleanCss.
JS: Compressed with no Sourcemaps, ES2015, Uglify.
Images: Optimized
```

##### `No -d or -t`

###### Production Build (default)

```
HTML: Minified
Styles: Compressed with no Sourcemaps, Order Properties, Autoprefixer, CleanCss.
JS: Compressed with no Sourcemaps, ES2015, Uglify.
Images: Optimized
```

#### Main

##### `gulp build` or `gulp`

Build a new site.

###### Sequenced Run Commands:

```
1. clean
2. build:images
3. build:fonts
4. build:scripts
5. build:styles
6. build:jekyll
7. build:html
```

##### `gulp serve`

Static Server + watching files. Only rebuild site if `--rebuild` option is passed to serve command.

###### Sequenced Run Commands:

```
1. build <- If flagged with --rebuild
2. watch
```

_Note:_ By default, `gulp serve` runs as a Development Build because its intended to run locally only. If you'd like to see what Production Build on `gulp serve` would look like, run with the `--test` flag.

##### `gulp watch`

Watches for site changes to stream or rebuild static build. Uses **BrowserSync** to server static build, middleware for 404 errors and pretty/vanity urls, Self Signed Certificate for https. _Note:_ By default, `gulp serve` runs as a Development Build because its intended to run locally only. If you'd like to see what Production Build on `gulp serve` would look like, run with the `--test` flag.

##### `gulp reload`

Reloading via BrowserSync

##### `gulp clean`

Deletes entire processed build, `_sites` directory.

#### Jekyll

##### `gulp build:jekyll`

Runs the Jekyll build command.

###### Flags

```
Development Build: --d or --dev or --development
Test Build: --t or --test
```

##### `gulp jekyll:check`

Special task for checking your Jekyll Setup.

```
Development Build: --d or --dev or --development
Test Build: --t or --test
```

##### `gulp watch:jekyll`

Special task for building the site then reloading via BrowserSync.

###### Sequenced Run Commands:

```
1. build:jekyll
2. build:html
3. reload
```

#### Styles

##### `gulp build:styles`

Builds all site styles.

###### Sequenced Run Commands:

```
1. build:styles:embed
2. build:styles:main
3. build:styles:css
```

##### `gulp build:styles:main`

Main site SCSS stylesheets, the target import stylesheet is `_assets/styles/styles.scss`. Uses Sass compiler to process styles, adds vendor prefixes, minifies, then outputs file to the appropriate location for appropriate environments.

##### `gulp build:styles:embed`

SCSS stylesheets for embedding styles throughout the theme. Any SCSS stylesheet that is prefixed with `embed-` will be processed then added to the `_html/includes/css` to for usage. Use Jekyll Tag `{% embed_css src:'PATH' %}` to embed styles into markup.

##### `gulp build:styles:standalone`

For vendor or plain css, add to the `_assets/styles/standalone` directory. This copies stylesheets to the build directory for usage.

##### `gulp clean:styles`

Deletes all processed site styles.

#### Scripts

##### `gulp build:scripts`

Concatenates and uglifies global JS files and outputs result to the appropriate location for appropriate environments.

##### `gulp build:scripts:main`

Main site scripts; concatenates and uglifies global JS files and outputs result to the appropriate location for appropriate environments.

##### `gulp build:scripts:standalone`

For vendor or plain scripts, add to the `_assets/js/standalone` directory. This copies scripts to the build directory for usage.

##### `gulp lint:scripts`

Shows JS Lint warnings and errors based on the eslint rule sets `eslint:recommended` and `google` located in the `package.json` file. 

##### `gulp lint:scripts:fix`

Fixes JS Lint warnings and errors based on the eslint rule sets `eslint:recommended` and `google` located in the `package.json` file. 

##### `gulp watch:scripts`

Watches for javascript changes, rebuilds the them then reload BrowserSync.

##### `gulp clean:scripts`

Deletes all processed scripts.

#### Images

##### `gulp build:images`

Builds and optimizes all site images/files.

#### Sequenced Run Commands:

```
1. build:images:site
2. build:images:media
3. optimize:images
```

##### `gulp build:images:site`

Copies theme specific images/files into image build directory. File types: `png, jpg, jpeg, gif, svg`

##### `gulp build:images:media`

Copies uploaded media images/files into image build directory. File types: `png, jpg, jpeg, gif, svg, pdf, zip, eps`

##### `gulp optimize:images`

Optimizes media and theme specific images/files.

##### `gulp clean:images`

Deletes all processed images.

#### Fonts

##### `gulp build:fonts`

Copies fonts for `_assets/fonts` to font build directory.

##### `gulp clean:fonts`

Deletes all processed fonts.

#### HTML

##### `gulp build:html`

Runs the HTML build command that minifies code in Test/Production Environments.

#### Misc.

##### `gulp update:gems`

Updates Ruby gems.

##### `gulp cache:clear`

Clears the gulp cache. Currently this just holds processed images.

##### `gulp pagespeed`

Run PageSpeed Insights for Mobile & Desktop. Custom site urls: --site=https://www.example.com

***

## Need Help?

For questions, issues, deletions or additions, please feel free to submit a [issue request](https://github.com/HigherEducation/JAMstack-Starter-Lite/issues).
