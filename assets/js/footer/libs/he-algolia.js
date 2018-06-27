/**
 * Algolia: Filters Toggle
 */
(function($) {
  if (!$('.filters').length) {
    return;
  }

  $(window).load(function() {
    $('.filters').on('click', '.js-toggle-category', function() {
      $(this)
        .closest('.filter-category')
        .toggleClass('is-active');
    });
  });
})(jQuery);
