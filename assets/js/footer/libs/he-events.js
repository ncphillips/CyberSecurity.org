/**
 * Events: JS Collapse All, JS Expand All
 */
(function($) {
  // Event: Collapse All in Collections
  $('body').on('click', '.js-collapse-all', function() {
    let $this = $(this);

    $this
      .text('Collapsed')
      .prop('disabled', true)
      .siblings('.js-expand-all')
        .text('Expand All')
        .prop('disabled', false);

    $this
      .parents('.js-children-toggle')
      .removeClass('is-expanded-all')
      .addClass('is-collapsed-all')
      .find('.js-target')
        .removeClass('is-active');
  });

  // Event: Expand All in Collections
  $('body').on('click', '.js-expand-all', function() {
    let $this = $(this);

    $this
      .text('Expanded')
      .prop('disabled', true)
      .siblings('.js-collapse-all')
        .text('Collapse All')
        .prop('disabled', false);

    $this
      .parents('.js-children-toggle')
      .removeClass('is-collapsed-all')
      .addClass('is-expanded-all')
      .find('.js-target')
        .addClass('is-active');
  });
})(jQuery);


/**
 * Event: JS Toggle
 */
(function($) {
  $('body').on('click', '.js-toggle', function() {
    let $this = $(this);

    // If toggles body class using data-bodyclass
    if ($this.attr('data-bodyclass')) {
      $('body').toggleClass($this.data('bodyclass'));
    }

    // Toggle closest .js-target
    $this.closest('.js-target').toggleClass('is-active');
  });
})(jQuery);


/**
 * Event: Scroll To & Jump To
 */
(function($) {
  // Event: Scroll To
  let jumpTo = function(waypoint) {
    let id        = waypoint.substr(1);
    let $waypoint = $('#' + id).length ? $('#' + id) : $('[data-waypoint="' + id + '"]');

    if (!$waypoint.length) {
      return;
    }

    $('body').removeClass('is-active-subnav');
    $('html, body').animate({scrollTop: $waypoint.offset().top - ($('.nav-sticky-fixed').height() + 15)}, 1000);
  };

  // Existing Hash
  if (window.location.hash.length !== 0) {
    jumpTo(window.location.hash);
  }

  // Scroll To Click
  $('body').on('click', 'a[href^="#"]', function() {
    if ($(this).attr('href') === "#") {
      return;
    }

    jumpTo($(this).attr('href'));
  });
})(jQuery);
