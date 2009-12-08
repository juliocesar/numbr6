$(document).ready(function() {
  var slides = $('.slide');
  window.slides = slides;
  slides
    .hide()
    .filter(':first')
      .show();
  $('button.previous').click(function() {
    if (slides.filter(':visible').prev('.slide').length) {
      slides
        .filter(':visible')
        .hide()
        .prev()
          .show();      
    }
  });
  $('button.next').click(function() {
    if (slides.filter(':visible').next('.slide').length) {
      slides
        .filter(':visible')
        .hide()
        .next()
          .show();      
    }
  });
});