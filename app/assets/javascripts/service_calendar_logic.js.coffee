$(document).ready ->
  # $(".visit_name").live 'mouseover', ->
  $(".visit_name").qtip
    overwrite: false
    content: "Click to rename your visits."
    position:
      corner:
        target: 'bottomLeft'
    show:
      ready: false

  # $('.visit_day').live 'mouseover', ->
  $('.visit_day').qtip
    overwrite: false
    content: "Click to set the visits day. All days must be in numerical order. Ex. 1, 2, 4, 9"
    position:
      corner:
        target: 'topLeft'
        tooltip: 'bottomLeft'
    show:
      ready: false

  # $('.visit_window').live 'mouseover', ->
  $('.visit_window').qtip
    overwrite: false
    content: "Click to set the window period the visit can be completed."
    position:
      corner:
        target: 'topLeft'
        tooltip: 'bottomLeft'
    show:
      ready: false

  $('.jump_to_visit').qtip
    overwrite: false
    content: "Select the visit you would like to view."
    position:
      corner:
        target: 'topLeft'
        tooltip: 'bottomLeft'
    show:
      ready: false

  $('#service_calendar').tabs
    show: (event, ui) -> 
      $(ui.panel).html('<div class="ui-corner-all" style = "border: 1px solid black; padding: 25px; width: 200px; margin: 30px auto; text-align: center">Loading data....<br /><img src="/assets/spinner.gif" /></div>')
    select: (event, ui) ->
      $(ui.panel).html('<div class="ui-corner-all" style = "border: 1px solid black; padding: 25px; width: 200px; margin: 30px auto; text-align: center">Loading data....<br /><img src="/assets/spinner.gif" /></div>')

  # $('.billing_type_list').live 'mouseover', ->
  $('.billing_type_list').qtip
    overwrite: false
    content: 'R = Research<br />T = Third Party (Patient Insurance)<br />% = % Effort'
    position:
      corner:
        target: 'topMiddle'
        tooltip: 'bottomLeft'
    show:
      ready: false
    style:
      tip: true
      border:
        width: 0
        radius: 4
      name: 'light'
      width: 260

  changing_tabs_calculating_rates = ->
    arm_ids = []
    $('.arm_calendar_container').each (index, arm) ->
      if $(arm).is(':hidden') == false then arm_ids.push $(arm).data('arm_id')

    i = 0
    while i < arm_ids.length
      calculate_max_rates(arm_ids[i])
      i++

  if $('.line_item_visit_template').is(':visible')
    changing_tabs_calculating_rates()
  else if $('.line_item_visit_billing').is(':visible')
    changing_tabs_calculating_rates()
  else if $('.line_item_visit_quantity').is(':visible')
    changing_tabs_calculating_rates()
  else if $('.line_item_visit_pricing').is(':visible')
    changing_tabs_calculating_rates()

