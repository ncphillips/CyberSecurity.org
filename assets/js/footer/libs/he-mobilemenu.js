/**
 * Mobile Menu
 */
(function($) {
  if (!$('.has-children').length) {
    return;
  }

  // Variables
  let resizeTimer;

  // Event: Mobile Submenu Children
  $('html').on('click', '.is-active-mobile .has-children > a', function(ev) {
    ev.preventDefault();
    $(this).parent('.has-children').toggleClass('is-active');
  });

  // Event: Content Click to close menu
  $('html').on('click', '.is-active-mobile .site-content', function(ev) {
    ev.preventDefault();
    $('body').removeClass('is-active-mobile');
  });

  // Event: Window Resize, remove is-active-mobile on desktop
  $(window).on('resize', function(e) {
    clearTimeout(resizeTimer);

    resizeTimer = setTimeout(function() {
      if (!$('.is-active-mobile').length || $(window).width() < 980) {
        return;
      }

      $('body').removeClass('is-active-mobile');
    }, 250);
  });
})(jQuery);
