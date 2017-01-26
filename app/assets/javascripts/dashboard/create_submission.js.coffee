$ ->
  $('#submissionModal').on 'shown.bs.modal', ->
    $('.selectpicker').selectpicker()
    $('#datetimepicker').datetimepicker()
    $('.create-submission').on 'click', ->
      $('.form-group').removeClass('has-error')
      $('span.help-block').remove()
      values = {}
      $.each $('.new_submission').serializeArray(), (i, field) ->
        regEx = /[\[]]/
        if regEx.test("#{field.name}")
          console.log $('select[name="#{field.name}"]')
          values[field.name] = $('select[name="#{field.name}"]').val()
        else
          values[field.name] = field.value
      serviceId = values["submission[service_id]"]
      $.ajax
        url: "/services/#{serviceId}/additional_details/submissions"
        type: 'POST'
        data: values

