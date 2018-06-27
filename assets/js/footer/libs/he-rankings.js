/**
 * Rankings - Heights
 */
(function($) {
  if (!$('.rankings').length) {
    return;
  }

  // Variables
  let $ranking_rows = $('.rankings .title');

  // Function: Set Ranking Heights
  let setRankHeights = function() {
    $ranking_rows.each(function(index) {
      let maxHeight = Math.max.apply(null, $(this).map(function() {return $(this).outerHeight();}).get());
      $(this).siblings().not('.content').outerHeight(maxHeight);
    });
  };

  // Events: Initial & Window Resize Function Call
  setRankHeights();
  $(window).on('resize', setRankHeights);
})(jQuery);
