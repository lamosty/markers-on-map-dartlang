#= require application

$ = jQuery

$ ->
  # Page scrolling
  $('.navbar a[data-target]').click((e) ->
    e.preventDefault()
    $('html, body').animate({
      scrollTop: $('#' + $(this).data('target')).offset().top

    }, 500)
  )

  # Unit Intro slider switching mechanism
  $('input[type="radio"]').on('click', () ->
    clickedRadio = $(this).val()

    $('.floats.visible').removeClass('visible').addClass('hidden')

    $('.' + clickedRadio).closest('.floats').removeClass('hidden')
      .addClass('visible')
  )

