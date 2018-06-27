/**
 * Sticky Navigation
 */
(function($) {
  if (!$('.nav-sticky').length) {
    return;
  }

  $('.nav-sticky').waypoint({
    handler: function(direction) {
      if (direction == 'down') {
        $('body').addClass('is-active-sticky');
      } else {
        $('body').removeClass('is-active-sticky');
      }
    },
  });
})(jQuery);


/**
 * Subnavigation + Waypoints
 */
(function($) {
  if (!$('[data-waypoint]').length || !$('.nav-sub').length) {
    return;
  }

  // Sub Navigation - Mouse Leave Trigger
  $('.js-rollout-subnav').on('mouseleave', function() {
    $('body').removeClass('is-active-subnav');
  });

  // Waypoints
  $('[data-waypoint]').waypoint({
    handler: function(direction) {
      // Navigational Item
      let $navTrigger = $('[href="#' + $(this.element).attr('data-waypoint') + '"]');

      // Remove: Is Active
      $('.nav-sub a.is-active').removeClass('is-active');

      if (direction == 'down') {
        $navTrigger.addClass('is-active');
        $('.js-label').text($navTrigger.text());
      } else {
        // Previous: Navigational Item
        let $prevTrigger = $navTrigger.closest('li').prev('li').find('a');

        if ($prevTrigger.length) {
          $prevTrigger.addClass('is-active');
          $('.js-label').text($prevTrigger.text());
        } else {
          $('.js-label').text('Quickly View Page Content');
        }
      }
    },
    offset: $('.nav-sticky').height() + 15,
  });
})(jQuery);
