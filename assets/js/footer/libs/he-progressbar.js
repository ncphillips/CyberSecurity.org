/**
 * Progress Bar
 */
(function($) {
  if (!$('.progress-bar').length) {
    return;
  }

  $(document).on('ready', function() {
    let $progressBar = $('.progress-bar'), max, value;

    // Progress Bar Build
    let progressBar = function() {
      max   = ($(document).height() - $(window).height());
      value = $(window).scrollTop();

      $progressBar.attr('max', max);
      $progressBar.attr('value', value);
    };

    // Jump To On Click
    $($progressBar).click(function(ev) {
      let x            = (ev.pageX - $(this).offset().left);
      let clickedValue = (x * this.max / this.offsetWidth);
      let jumpPosition = Math.floor(clickedValue);
      $('html, body').animate({scrollTop: jumpPosition}, 1000);
    });

    // Initial, Scroll & Window Resize Function Call
    progressBar();
    $(document).on('scroll', progressBar);
    $(window).on('resize', progressBar);
  });
})(jQuery);
