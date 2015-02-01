cb.togglePublications = ->
  $('.page').on 'click', '.hide_pub', (event) ->
    content_id = $(this).attr('data-content-id')
    $('#publications_for_'+content_id).hide()
    $(this).hide()
    $('#show_pub_'+content_id).show()
    cleanPublishingMessages(content_id)
    event.preventDefault()

cb.triggerPublications = ->
  $('.page').on 'click', '._publishButn.togl-on', (e) ->
    unPublish $(this)
    e.preventDefault()
  $('.page').on 'click', '._publishButn.togl-off', (e) ->
    publish $(this)
    e.preventDefault()
  $('.page').on 'click', '._publishButn.togl-work', (e) ->
    e.preventDefault()
  $('.page').on 'click', '._timeButn', (e) ->
    timePanel = $(this).next('._timeZone')
    if timePanel.is(':visible')
      hideTimePanel(timePanel)
    else
      publicationId = $(this).nextAll('._publishButn').attr('data-publication-id')
      showTimePanel(publicationId, timePanel)
    e.preventDefault()
  $('.page').on 'click', '._changeTime', (e) ->
    timePanel = $(this).closest('._timeZone')
    updateExpiration(timePanel, $(this).attr('href'), $(this).attr('data-expire-in'))
    e.preventDefault()

cb.decorateMenuButtons = ->
  $('.page').on 'click', '.triggerMenu', (event) ->
    menu_id = '#' + $(this).attr('data-menu-id')
    $(menu_id).toggle()
    event.preventDefault()

cb.decorateMobileButtons = ->
  $('.page').on 'click', '._butnMobMenu', (event) ->
    butnmob = $(this).closest('._withButnMob').find('._butnMob')
    if butnmob.hasClass('show')
      butnmob.removeClass('show')
    else
      $('._butnMob').removeClass('show')
      butnmob.addClass('show')
    event.preventDefault()

cb.displayPublicationZone = (publications_url, targetElt) ->
  $.ajax url: publications_url,
         cache: false,
  .done (data) ->
    targetElt.html(data)

publish = (button) ->
  cleanPublishingMessages(button.data('content-id'))
  $.ajax  button.attr('href'),
          type: 'POST',
          dataType: 'json',
          cache: false,
          data: {publication: {channel_id: button.data('channel-id'), content_id: button.data('content-id')}},
          beforeSend: ( xhr ) ->
            toggleButtonToWorking(button)
  .done (data) ->
    toggleButtonToPublished(button, data.publication.id, data.unpublish_path, data.publication.permalink, data.show_expiration_path)
    displayMessage(button.data('content-id'), data.new_section_message) if data.new_section_created
    setPublicationsCount button.data('content-id'), data.publications_count
  .fail (data) ->
    displayPublishingError(button.data('content-id'), data.responseJSON.error.msg)
    toggleButtonToUnpublished(button)

unPublish = (button) ->
  cleanPublishingMessages(button.data('content-id'))
  $.ajax  button.attr('href'),
          type: 'DELETE',
          dataType: 'json',
          cache: false,
          beforeSend: ( xhr ) ->
            toggleButtonToWorking(button)
  .done (data) ->
    toggleButtonToUnpublished(button, data.publish_path)
    displayMessage(button.data('content-id'), data.message) if data.message
    setPublicationsCount button.data('content-id'), data.publications_count
  .fail (data) ->
    displayPublishingError(button.data('content-id'), data.responseJSON.error.msg)
    toggleButtonToPublished(button)

displayUnpublicationMessage = (message) ->


updateExpiration = (panel, href, expireIn) ->
  $.ajax  href,
          type: 'PUT',
          dataType: 'json',
          cache: false,
          data: {expire_in: expireIn}
  .done (data) ->
    if data.updated?
      if data.expire_at?
        panel.prev('._timeButn').removeClass('togl-on').addClass('active')
      else
        panel.prev('._timeButn').removeClass('active').addClass('togl-on')
    hideTimePanel(panel)
  .fail (data) ->
    hideTimePanel(panel)


toggleButtonToPublished = (button, publicationId=null, unpublishPath=null, permalink=null, expirationPath=null) ->
  button.removeClass('togl-work')
  button.addClass('togl-on combo')
  button.data('publication-id', publicationId) if publicationId
  button.attr('href', unpublishPath) if unpublishPath
  seeButton = button.next('._seePublication')
  seeButton.attr('href', permalink) if permalink
  seeButton.show()
  timeButton = button.prevAll('._timeButn')
  timeButton.attr('href', expirationPath) if expirationPath
  timeButton.show()
  button.prevAll('._timeZone').hide()

toggleButtonToUnpublished = (button, publishPath=null) ->
  button.removeClass('togl-work')
  button.removeClass('combo')
  button.addClass('togl-off')
  button.data('publication-id', null)
  button.attr('href', publishPath) if publishPath
  seeButton = button.next('._seePublication')
  seeButton.attr('href', null) if publishPath
  seeButton.hide()
  button.prevAll('._timeButn').removeClass('active').addClass('togl-on').hide()
  button.prevAll('._timeZone').hide()

toggleButtonToWorking = (button) ->
  button.removeClass('togl-on')
  button.removeClass('togl-off')
  button.addClass('togl-work')
  button.prevAll('._timeZone').hide()

hideTimePanel = (panel) ->
  panel.hide()

showTimePanel = (publicationId, panel) ->
  $('._timeZone').hide()
  $.ajax  panel.prevAll('._timeButn').attr('href'),
          cache: false
  .done (data) ->
    panel.html(data).show()

setPublicationsCount = (contentId, publicationsCount) ->
  $("#pub_count_#{contentId}").html(publicationsCount)

displayPublishingError = (contentId, message) ->
  $("#publications_error_#{contentId}").html(message)
  $("#publications_error_#{contentId}").show()

displayMessage = (contentId, message) ->
  $("#publications_info_#{contentId}").html(message)
  $("#publications_info_#{contentId}").show()

cleanPublishingMessages = (contentId) ->
  $("#publications_error_#{contentId}").html('')
  $("#publications_error_#{contentId}").hide()
  $("#publications_info_#{contentId}").html('')
  $("#publications_info_#{contentId}").hide()
