$ ->
  $('#released_on')
  .datepicker(changeYear: true, yearRange: '1960:2020')
  $('#like input').click(event) ->
    event.preventDefault()
    $.post(
      $('#like form').attr('action')
      (data) -> $('#like p').html(data)
      .effect('hightlight', color: '#fcd')
    )
