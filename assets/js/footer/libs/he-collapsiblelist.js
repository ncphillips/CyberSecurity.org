/**
 * Collapsible List - Accordian, Horizontal Tab, Vertical Tab
 */
(function($) {
  if (!$('.collapsible').length) {
    return;
  }

  // Open First Item for each list
  $('.collapsible').each(function() {
    let $definitionList = $(this);

    if ($definitionList.find('.collapsible-title.is-active').length) {
      return;
    }

    $definitionList
      .find('.collapsible-title')
      .eq(0)
      .addClass('is-active');
  });

  // Expand/Collapse
  $('.collapsible').on('click', '.collapsible-title', function() {
    let $title = $(this);

    if ($title.parents('.collapsible').hasClass('type-accordion')) {
      $title.toggleClass('is-active');
      return;
    }

    $title
      .addClass('is-active')
      .siblings('.collapsible-title')
      .removeClass('is-active');
  });

  // Expand All -- Accordion Style Only
  $('.js-collapsible-expand-all').on('click', function(ev) {
    ev.preventDefault();

    $(this)
      .parents('.collapsible-controls')
      .next('.type-accordion')
      .find('.collapsible-title')
      .addClass('is-active');
  });

  // Collapse All -- Accordion Style Only
  $('.js-collapsible-collapse-all').on('click', function(ev) {
    ev.preventDefault();

    $(this)
      .parents('.collapsible-controls')
      .next('.type-accordion')
      .find('.collapsible-title')
      .removeClass('is-active');
  });
})(jQuery);
