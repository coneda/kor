var Clipboard = new Object();

Clipboard.add_user_group = function() {
  var tpl = KorTemplate.get('#user_group_form');
  tpl.submit(function(event){
    var value = $(event.currentTarget).find('input[type=text]').val();

    $.post('/user_groups', {'user_group[name]': value}, function(data){
      $('#clipboard_action_supplement').load('/tools/new_clipboard_action', {
        clipboard_action: 'add_to_user_group',
        selected_entity_ids: Clipboard.selected_entity_ids()
      });
    });

    return(false);
  });
  $('#clipboard_action_supplement').html(tpl);
}

Clipboard.setup = function() {
  $('#clipboard_action_selector').change(function(event) {
    params = {
      'clipboard_action': $(this).val(),
      'selected_entity_ids': Clipboard.selected_entity_ids()
    };
    $('#clipboard_action_supplement').load('/tools/new_clipboard_action', $.param(params), Kor.ajax_not_loading);
  });
  
  $('#clipboard_entity_selector').change(function(event){
    Clipboard.select_clipboard_content_by_kind(this.value);
  });
  
  $(document).on('click', 'a.add_user_group', function(event){
    Clipboard.add_user_group()
    return false;
  });
}

Clipboard.select_clipboard_content_by_kind = function(kind) {
  checkboxes = $('#clipboard_form input[type=checkbox]');
  checkboxes.attr('checked', false);
  
  if (kind == -1) {
      checkboxes.attr('checked', true);
  } else {
    checkboxes.each(function(i, e) {
      kind_field = $(e).parent().find("input[name='kind[]']");
      if (kind_field.val() == kind) {
        $(e).attr('checked', true);
      }
    });
  }
  
}

Clipboard.selected_entity_ids = function() {
  var check_boxes = $("input[type=checkbox]:checked");
  var result = check_boxes.map(function(i, e) {
    return $(e).val();
  });
  
  return $.makeArray(result);
}

$(document).ready(function(event) {
  Clipboard.setup();
});
