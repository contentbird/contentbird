cb.decorateImageWidgets = () ->
  $('._imageWidget').each (index) ->
    cb.decorateImageWidget $(this)

cb.decorateImageWidget = (widget) ->
  displayWidget(widget)
  widget.on 'click', '._delImage', (event) ->
    deleteImage(widget)
    event.preventDefault()
  widget.on 'click', '._addImage', (event) ->
    cb.openAjaxModal($(this).attr('href'))
    event.preventDefault()

cb.setImageField = (fieldName, imageName) ->
  widget = $("._imageWidget._field_#{fieldName}")
  widget.find('._imageValue').val(imageName)
  displayImage(widget)

displayEmptyWidget = (widget) ->
  widget.find('._addImageZone').show()
  widget.find('._imageContainer').hide()

displayImage = (widget) ->
  valueField        = widget.find('._imageValue')
  displayThumbnail  = (valueField.attr('data-display-thumbnail') == 'true')
  imageThumbnailUrl = if displayThumbnail then cb.thumbnailUrl(valueField.attr('data-base-media-url')+valueField.val()) else (valueField.attr('data-base-media-url')+valueField.val())
  valueField.after("<img src=\"#{imageThumbnailUrl}\" class=\"_imagePreview imagePreview\">")
  widget.find('._addImageZone').hide()
  widget.find('._imageContainer').show()

deleteImage = (widget) ->
  widget.find('._imagePreview').remove()
  widget.find('._imageValue').val('')
  displayEmptyWidget(widget)

displayWidget = (widget) ->
  img_field = widget.find('._imageValue')
  if img_field.val()
    displayImage(widget)
  else
    displayEmptyWidget(widget)
