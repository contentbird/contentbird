cb.decorateChannelSubscriptions = ->
  $('._subscriptionsForm').on 'click', '#add_contact', (e) ->
    newEmailField = $('#new_contact_email')
    if newEmailField.val() && newEmailField.hasClass('valid')
      $.ajax  $(this).attr('href'),
        type: 'POST',
        dataType: 'json',
        cache: false,
        data: {email: newEmailField.val()},
        beforeSend: (xhr) ->
          resetSubscriptionError()
          hideAllSubscriptionNotices()
      .done (data) ->
        handleContactResponse(data)
        newEmailField.val('')
      .fail (data) ->
        displaySubscriptionError(data)
    e.preventDefault()

  $('._subscriptionsForm').on 'click', '._removeFields', (e) ->
    hideAllSubscriptionNotices()

  submitContactOnEnterKey()


handleContactResponse = (data) ->
  if data.your_own_email
    displaySubscriptionNotice data.your_own_email.msg
  else
    if $('._channelSubscription:visible').size() < 10
      if $("#contact_#{data.id}").size() > 0
        unDeleteSubscription(data.id)
      else
        addSubscriptionToList data
    else
      $('#maxListSize').show()

displaySubscriptionError = (data) ->
  $('._subscriptionsError').html(data.responseJSON.error.msg).show()

resetSubscriptionError = (data) ->
  $('._subscriptionsError').html('').hide()

displaySubscriptionNotice = (notice) ->
  $('#subscription_notice').html(notice).show()

hideAllSubscriptionNotices = ->
  $('#maxListSize, #subscription_notice').hide()

unDeleteSubscription = (contactId) ->
  $("#contact_#{contactId}").show()
  $("#contact_#{contactId} ._destroyRecord").val(false)

addSubscriptionToList = (data) ->
  newContact = data
  newContact.position = $('._channelSubscription').size() + 1
  subscription = $(tmpl("cb-template-channel-subscription", newContact))
  $('#subscriptions_list').append(subscription)

submitContactOnEnterKey = () ->
  $(window).keydown (e) ->
    if e.keyCode == 13 && $('#new_contact_email').is(':focus')
      $('#add_contact').trigger('click')
      e.preventDefault()
      return false