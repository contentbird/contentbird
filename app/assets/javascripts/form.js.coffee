cb.decorateForms = ->
  $('form').on 'click', '._addFields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    fieldsHtml = $(this).data('fields').replace(regexp, time)
    lastFieldset = $(this).closest('form').find('fieldset')
    place_to_add_section
    if lastFieldset.length != 0
      place_to_add_section = lastFieldset.last()
      place_to_add_section.after(fieldsHtml)
    else
      place_to_add_section = $("##{$(this).data('addZone')}")
      place_to_add_section.append(fieldsHtml)
    decorateOptionsPanels($(this).parent('form').find('._withOptions'))
    decorateSortable()
    event.preventDefault()

  $('form').on 'click', '._removeFields', (event) ->
    $(this).prev('input[type=hidden]._destroyRecord').val('1')
    $(this).closest('fieldset').find('[required]').removeAttr('required');
    $(this).closest('fieldset').hide()
    event.preventDefault()

  $('form').on 'change', 'fieldset._channelSection select._typeSelect', (event) ->
    fieldset = $(this).closest('fieldset._channelSection')
    typeName = $(this).children('option:selected').text()
    fieldset.find('input._typeName').val(typeName)

  decorateOptionsPanels($('._withOptions'))
  decorateSortable()
  decorateSortableGallery()
  $('.fancy').fancySelect()
  polyfillHTML5Forms()

decorateOptionsPanels = (optionables) ->
  optionables.find('.inputError').closest('._withOptions').addClass('optionsVisible')

  optionables.on 'click', '.optionsShow', (event) ->
    $(this).closest('._withOptions').addClass('optionsVisible')
    event.preventDefault()

  optionables.on 'click', '.optionsHide', (event) ->
    $(this).closest('._withOptions').removeClass('optionsVisible')
    event.preventDefault()

decorateSortable = () ->
  setPositionsOnSortable()
  $('.sortable').sortable(placeholder: "sortable-placeholder", forcePlaceholderSize: true, handle: '._dragHandle').bind 'sortupdate', (e, ui) ->
    changePositions(e, ui)

decorateSortableGallery = () ->
  $('._sortableGallery').sortable(placeholder: "image-placeholder", handle: '._draggableImage')

setPositionsOnSortable = () ->
  list = $('.sortable').find('._sortItem')
  list.each (index) ->
    sibling_current_position = list.index($(this))
    $(this).find('._dragIndex').attr('value', sibling_current_position)

changePositions = (e, ui) ->
  list = ui.item.closest('.sortable').find('._sortItem')
  list.each (index) ->
    sibling_current_position = list.index($(this))
    $(this).find('._dragIndex').attr('value', sibling_current_position)

polyfillHTML5Forms = () ->
  H5F.setup($('form'),{invalidClass: "h5fError", requiredClass: 'h5fRequired'})