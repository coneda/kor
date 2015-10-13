var Attachments = new Object();

Attachments.add = function(event) {
  var container = $(event.currentTarget).parents('div.attachments');
  var id = container.attr('id');
  var template = KorTemplate.get('.attachment_' + id);
  container.append(template);
  return false;
}

Attachments.remove = function(event) {
  var attachment = $(event.currentTarget).parents('div.attachment');
  attachment.remove();
  return false;
}

Attachments.register_expert_search_events = function() {
  $(document).on('click', '.attachment_minus', Attachments.remove);
  $(document).on('click', '.attachment_plus', Attachments.add)

  $('#relation_conditions .commands a').click(function(event) {
    var attachments = $(event.currentTarget).parents('div.attachments');
    console.log(attachments);
    var kind_id = $('#query_kind_id').val();
    var attachment = $('<div>');
    $.ajax({
      url: '/tools/relational_form_fields',
      data: {'kind_id': kind_id},
      dataType: "html",
      success: function(data) {
        $(this).html(data);
      },
      context: attachment
    });
    attachments.append(attachment);
    return false;
  });
  
  $("select[name='query[kind_id]']").on('change', function(event){
    $.get('/tools/dataset_fields', {kind_id: $(this).val()}, function(data){
      $('#relation_conditions div.attachment').remove();
      $('.dataset_attributes').html(data);
    }, 'text');
  });
}
