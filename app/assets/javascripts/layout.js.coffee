cb.animateLayout = ->
  $("#accountLink").on 'click', (e) ->
    $('#accountNav, #page').toggleClass 'openLeft'
    e.preventDefault()

  $("#touchNavLink").on 'click', (e) ->
    $('#page').toggleClass 'openLeft'
    e.preventDefault()

  $("#touchAccountLink").on 'click', (e) ->
    $('#page').toggleClass 'openRight'
    e.preventDefault()

  $("#collapseMenu").on 'click', (e) ->
    applyToAllMenus('toggleClass')
    localStorage["cb.collapseMenu"] = if localStorage["cb.collapseMenu"] == 'true' then 'false' else 'true'
    e.preventDefault()

  id = null
  $(window).resize ->
    clearTimeout id
    id = setTimeout(doneResizing, 100)

  adaptMenusToScreenSize()

cb.stickyHeader = ->
  headerTop = $('#headerTop')
  sticky_navigation_offset_top = headerTop.offset().top
  sticky_sign_up_banner = =>
    scroll_top = $(window).scrollTop()
    if scroll_top > sticky_navigation_offset_top
      headerTop.addClass('fixed')
    else
      headerTop.removeClass('fixed')

  sticky_sign_up_banner()

  $(window).scroll ->
    sticky_sign_up_banner()

hideOpenedMenus = ->
  $('#accountNav, #page').removeClass('openLeft').removeClass('openRight')

adaptMenusToScreenSize = ->
  if Modernizr.mq('screen and (max-width:768px)')
    applyToAllMenus('removeClass')
  else
    if Modernizr.mq('screen and (min-width:768px)') && localStorage["cb.collapseMenu"] == 'true'
      applyToAllMenus('addClass')

applyToAllMenus = (method) ->
  $(".mainMenuItem")[method]('collapseMenu')
  $("#mainNav")[method]('widthMenu')
  $('#accountNav, #page')[method]('iconMenu')

doneResizing = ->
  hideOpenedMenus()
  adaptMenusToScreenSize()
