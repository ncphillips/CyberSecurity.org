/**
 * Styleguide - Clipboards
 */
(function($) {
  if (!$('.js-clipboard').length) {
    return;
  }

  $('.js-clipboard').click(function() {
    $(this)
      .parents('code')
      .next('.clipboard-area')
      .find('textarea')
      .select();
    document.execCommand('copy');
  });
})(jQuery);
