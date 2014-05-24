var CollectionSelector = new Object();

CollectionSelector.fix_reload = function(hidden_field_value) {
  $(document).ready(function(){
    $("input[name$='[collection_ids]']").val(hidden_field_value);
  });
}

CollectionSelector.select_collections = function(event) {
  var dialog_div = $('#collection_selector_dialog').clone();
  var form_field_div = $(event.target).parents('.form_field');
  var selected_ids = form_field_div.find('input[type=hidden]').val().split(',');

  dialog_div.find('input[type=checkbox]').each(function(i, e){
    if ($.inArray($(e).val(), selected_ids) != -1) {
      $(e).attr('checked', true);
    } else {
      $(e).attr('checked', false);
    }
  });

  dialog_div.data('form_field_div', form_field_div);
  var buttons = {}
  buttons[CollectionSelector.button_cancel_label] = CollectionSelector.close_dialog
  buttons[CollectionSelector.button_all_none_label] = CollectionSelector.select_all_none
  buttons[CollectionSelector.button_apply_label] = CollectionSelector.retrieve_selection
  dialog_div.dialog({
    title: CollectionSelector.dialog_title,
    width: 400,
    buttons: buttons
  });
}

CollectionSelector.finish_dialog = function(dialog) {
  var collection_names = [];
  var collection_ids = [];

  dialog.find('input:checked').each(function(i, e){
    var collection_box = $(e).parents('.selectable_collection');
    collection_names.push(collection_box.find('.name').text());
    collection_ids.push($(e).val());
  });

  var form_field_div = dialog.data('form_field_div');
  form_field_div.find('input[type=hidden]').val(collection_ids.join(','));
  form_field_div.find('.value').text(collection_names.join(', '));

  dialog.dialog('close');
}

CollectionSelector.retrieve_selection = function() {
  CollectionSelector.finish_dialog($(this));
}

CollectionSelector.select_all_none = function() {
  var all = true;
  $(this).find('input[type=checkbox]').each(function(i , e){
    if ($(e).is(':checked') != true) {
      all = false;
    }
  });

  $(this).find('input[type=checkbox]').each(function(i , e) {
    $(e).attr('checked', !all);
  });
}

CollectionSelector.close_dialog = function() {
  $(this).dialog('close');
}
