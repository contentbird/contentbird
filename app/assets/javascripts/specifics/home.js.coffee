cb.decorateHomeImage = () ->
  scaleHomeImage()
  $(window).resize ->
    scaleHomeImage()

scaleHomeImage = () ->
  $('#homeImage').css 'height', ($(window).height())+'px'

cb.smoothAnchors = (headerHeight) ->
  $('a[href*=#]:not([href=#])').click () ->
    if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') && location.hostname == this.hostname)
      target = $(this.hash)
      target = if target.length then target else $('[name=' + this.hash.slice(1) + ']')
      if (target.length)
        $('html,body').animate({scrollTop: target.offset().top - headerHeight}, 1000)
        return false

cb.animateHowItWorksSvg = () ->
  cb.howItWorksPlayed = false
  total_frames = path = length = myobj = null

  myobj           = document.getElementById('myobj').cloneNode(true)

  animationHeight = $('#myobj').closest('.box').offset().top
  sectionTitleHeight = $('#myobj').closest('section').find('.box').first().offset().top - $('#myobj').closest('section').offset().top
  triggerHeight   = animationHeight - sectionTitleHeight - $('#headerTop').height()

  ids = {step1: [0..8], step2_content: [9..21], step2_links: [22, 23], step2_posts: [24..49], step3_link: [50..55], step3_gone: [56..61], checks: [2,3,8], right_link: [23], right_arrow: [5..7], right_post: [37..49] }

  init = () ->
    $('#replay-how-it-works').hide()
    total_frames = 60
    path = new Array()
    length = new Array()
    for i in [0..61]
      path[i] = document.getElementById('i'+i)
      l = path[i].getTotalLength()
      length[i] = l
      path[i].style.strokeDasharray = l + ' ' + l
      path[i].style.strokeDashoffset = l

  draw = () ->
    resetStepTexts()
    hightLightStepText(1)
    drawStep 'step1', 0, () ->
      setTimeout () ->
        hightLightStepText(2)
        drawStep 'step2_content', 0, () ->
          removeItems 'checks'
          drawStep 'step2_links', 0, () ->
            drawStep 'step2_posts', 0, () ->
              setTimeout () ->
                hightLightStepText(3)
                removeItems 'right_link'
                removeItems 'right_arrow'
                drawStep 'step3_link', 0, () ->
                  removeItems 'right_post'
                  drawStep 'step3_gone', 0, () ->
                    $('#replay-how-it-works').show()
              , 1000
      , 1000

  drawStep = (stepName, currentFrame, callback) ->
    progress = currentFrame / total_frames
    currentFrame++
    for j in ids[stepName]
      path[j].style.strokeDashoffset = Math.floor(length[j] * (1 - progress))
    window.requestAnimationFrame () ->
      if (currentFrame / total_frames) > 1
        callback()
      else
        drawStep stepName, currentFrame, callback

  hightLightStepText = (stepNumber) ->
    $("#animStep#{stepNumber}").addClass('active')

  resetStepTexts = () ->
    $('._animStep').removeClass('active')

  removeItems = (stepName) ->
    for i in ids[stepName]
      document.getElementById('i'+i).style.display = "none";

  restoreItems = (stepName) ->
    for i in ids[stepName]
      document.getElementById('i'+i).style.display = "block";

  init()

  $(window).scroll ->
    if !cb.howItWorksPlayed && $(window).scrollTop() >= triggerHeight && $(window).scrollTop() <= triggerHeight + 300
      cb.howItWorksPlayed = true
      draw()


  $('#how-it-works').on 'click', '#replay-how-it-works', (e) ->
    rerun()
    e.preventDefault()

  rerun = () ->
    restoreItems('checks')
    restoreItems('right_link')
    restoreItems('right_arrow')
    restoreItems('right_post')
    old = document.getElementById('myobj')
    parent = old.parentNode
    parent.removeChild(old)
    parent.appendChild(myobj)
    init()
    draw()