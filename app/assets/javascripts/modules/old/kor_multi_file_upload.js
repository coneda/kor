var KorMultiFileUpload = new Object();

KorMultiFileUpload.setup = function(given) {
  this.options = Kor.reverse_merge(given, {
    'file_input': '#files',
    'queue_container_id': 'files_queue',
    'submit_button': '.upload_buttons input.submit',
    'reset_button': '.upload_buttons input.reset',
    'attach_to_transit': true,
    'transit_url': '/user_groups',
    'transit_name_input': '#transit_name',
    'collection_id_input': '#collection_id',
    'relate': 'input_and_current',
    'relation_name_input': '#relation_name',
    'relations': function() {return {};}
  });
  
  if ($(this.options.file_input).length > 0) {
    if (this.options.attach_to_transit) {
      this.setup_auto_complete();
    }
    
    this.setup_buttons();
    this.setup_file_selector();
  }
}

KorMultiFileUpload.setup_auto_complete = function() {
  $(this.options.transit).autocomplete({
    source: this.options.transit_url,
		minLength: 3
  });
}

KorMultiFileUpload.setup_file_selector = function() {
  $(this.options.file_input).uploadify({
    'uploader': '/flash/uploadify.swf',
    'expressInstall': '/flash/expressInstall.swf',
    'queueID': this.options.queue_container_id,
    'cancelImg': '/assets/cancel.png',
    'hideButton': true,
    'multi': true,
    'script': '/entities',
    'method': 'post',
    'height': 15,
    'wmode': 'transparent',
    'fileDataName': 'entity[medium_attributes][document]',
    'onComplete': KorMultiFileUpload.on_complete,
    'onSelect': KorMultiFileUpload.on_select,
    'sizeLimit': Kor.options.upload_size_limit
  });
}

KorMultiFileUpload.on_select = function(event, ID, fileObj) {
  var options = KorMultiFileUpload.options;
  $(options.submit_button).show();
  $(options.reset_button).show();
  return(true);
}

KorMultiFileUpload.setup_buttons = function() {
  $(this.options.submit_button).click(function(event){
    var options = KorMultiFileUpload.options;
    
    var params = {
      'flash_session_id': Kor.options.flash_session_key,
      'http_accept_header': 'application/javascript',
      'user_group_name': $(options.transit_name_input).val(),
      'entity[kind_id]': Kor.options.medium_kind_id,
      'entity[collection_id]': $(options.collection_id_input).val()
    };
    
    if (options.relate == 'input_and_current') {
      if ($('#relation_name')) {
        params['relation_name'] = $('#relation_name').val();
      }
    } else if (options.relate == 'data_and_param') {
      for (var i in options.relations()) {
        params['relations[' + i + '][]'] = options.relations()[i];
      }
    }
    
    $(options.file_input).uploadifySettings('scriptData', params);
    $(options.file_input).uploadifyUpload();
  });
  
  $(this.options.reset_button).click(function(event){
    var options = KorMultiFileUpload.options;
    $(options.file_input).uploadifyClearQueue();
    return false;
  });
}

KorMultiFileUpload.on_complete = function(event, ID, fileObj, response, data) {
  response = $.parseJSON(response);
  
  if (response.success) {
    return(true);
  } else {
    var div = $("<div><ul></ul></div>");
    div.attr('id', 'error_messages_for_' + ID);
    div.attr('title', 'Error Messages');
    var ul = div.find('ul');
    response.errors.each(function(e, i){
      var li = $('<li>');
      li.html(e.join(': '));
      ul.append(li);
    });
    div.attr('style', 'display: none');
      
    var link = $("<a>Error</a>");
    link.click(function(event){
      var ID = $(event.currentTarget).parents('.uploadifyQueueItem').attr('id').replace('files', '');
      $('#error_messages_for_' + ID).dialog('open');
    });
    
    var destination = $('#files' + ID + ' span.percentage');
    destination.html(' - ');
    destination.append(link);
    
    div.dialog({autoOpen: false});
    return(false);
  }
}
