var Application = new Object();
var Kor = new Object();

Application.register_input_focus_events = function() {
  $("body").on("focus", 'input[type=text], input[type=password], textarea', function(event) {
    $(event.currentTarget).addClass('focused');
  });
  $("body").on("blur", 'input[type=text], input[type=password], textarea', function(event) {
    $(event.currentTarget).removeClass('focused');
  });
  
  $('div.kor_submit').mouseover(function(event){
    $(this).find('input').addClass('highlighted_button');
  });
  
  $('div.kor_submit').mouseout(function(event){
    $(this).find('input').removeClass('highlighted_button');
  });
}

Application.focus_first_input = function() {
  $('input[type=text], input[type=password], textarea').first().focus();
}

Application.setup_kor_command_image_events = function() {
  var images = $('img.kor_command_image');

  images.mouseover(function(event) {
    var image = $(event.currentTarget);
    var new_src = image.attr('data-hover-url');
    image.attr('src', new_src);
  });
  
  images.mouseout(function(event) {
    var image = $(event.currentTarget);
    var new_src = image.attr('data-normal-url');
    image.attr('src', new_src);
  });
}

Application.setup_search_result_events = function() {
  $("body").on('mouseup', 'input.put_in_clipboard', function(event){
    var checkbox = $(this);
    var checked = checkbox.is(':checked');
    checkbox.attr('checked', !checked);
    checked = !checked;
    
    var params = {
      id: checkbox.attr('id').split('_').pop(),
      mark: (checked ? 'mark' : 'unmark')
    };
    
    $.getJSON('/mark', params, function(data) {
      Kor.notice(data.message);
    });
    
    return false;
  });
  
  $(document).on('click', 'input.put_in_clipboard', function(event){
    return false;
  });
}

Application.register_popups = function() {
  $('#templates .dialog_popup').dialog({autoOpen: false, width: 200});
  $(document).on('click', 'a.dialog_popup', function(event){
    var id = $(this).attr('id');
    $('.dialog_popup.' + id).dialog('open');
    return false;
  });
}

Application.setup_ajax = function() {
  $.ajaxSetup({
    dataType: "json",
    beforeSend: function(xhr) {
      // xhr.setRequestHeader('Accept', 'application/json');
      Kor.ajax_loading();
    },
    complete: function(xhr) {
      Kor.ajax_not_loading();
    }
  });
}

Application.setup = function() {
  Kor.setup_blaze();

  Application.setup_ajax();
  
  this.setup_kor_command_image_events();
  Kor.register_session_events();
  Kor.setup_help();
  Menu.setup();
  Panel.setup();
  Forms.setup();
  this.setup_search_result_events();
  this.register_input_focus_events();
  this.focus_first_input();
  this.register_popups();

  $('table').attr('cellspacing', 0);
  
  Attachments.register_expert_search_events();
}

Kor.setup_blaze = function() {
  $(document).on('click', 'a', function(event) {
    var link = $(this);
    var url = link.attr('href');
    if (url && url.match(/^\/entities\/\d+$/)) {
      var parts = url.split("/");
      var id = parts[parts.length - 1]
      window.location.href = '/blaze#/entities/' + id;
      event.preventDefault();
      return false;
    }
  });
}

Kor.ajax_loading = function() {$('#ajax_loading_indicator').fadeIn(200);}
Kor.ajax_not_loading = function() {$('#ajax_loading_indicator').fadeOut(200);}

Kor.notice = function(msg) {
  Kor.cleanup_message_area();
  var message_area = $('#message_area');
  var notices_div = message_area.find('.notices');
  
  if (notices_div.length == 0) {
    message_area.append($("<div class='notices'></div>"));
  }
  
  notices_div = message_area.find('.notices');
  notices_div.append(msg);
}

Kor.cleanup_message_area = function() {
  $('#message_area').empty();
}

Kor.register_session_events = function() {
  $(document).on('click', '#session_info .commands a', function(event){
    var link = $(event.currentTarget);
    var panel = $('#session_info_slide');
    
    if (panel.is(':visible')) {
      $.get('/tools/session_info', {'show': 'hide'});
      panel.slideUp(300);
    } else {
      $.get('/tools/session_info', {'show': 'show'});
      panel.slideDown(300);
    }
    
    return false;
  });
  
  if (!$('#session_info_content').is(':empty')) {
    $('#session_info').show()
  }
}

Kor.setup_help = function() {
  var help_div = $('#help');
  var help_button = $('#help_button');
  
  if ($('#help').text().match(/[^\n\s]/m)) {
    help_button.click(function(event) {
      help_div.dialog({
        width: 400,
        minWidth: 400,
        minHeight: 200
      });

      event.preventDefault();
    });
  
    help_button.show();
  }
}

/* KorTemplate */

var KorTemplate = new Object();

KorTemplate.get = function(selector) {
  var template = $('#templates ' + selector).clone()
  
  template.fill_in = function(selector, value) {
    this.find(selector).html(value);
  }
  
  template.set = function(selector, attribute, value) {
    this.find(selector).attr(attribute, value);
  }
  
  template.removeAttr('id');
  return template;
}


/* ImageQuickButtons */

var ImageQuickButtons = new Object();

ImageQuickButtons.mark = function(action, entity_id) {
  $.getJSON('/mark', {mark: action, id: entity_id}, function(data, textStatus){
    Kor.notice(data.message);
  });
}

ImageQuickButtons.register_events = function() {
  $(document).on('mouseover', '.kor_medium_frame', function(event) {
    $(event.currentTarget).find('.button_bar').show();
  });

  $(document).on('mouseout', '.kor_medium_frame', function(event) {
    $(event.currentTarget).find('.button_bar').hide();
  });

  $(document).on('click', ".kor_medium_frame .button_bar img[data-name=target]", function(event) {
    var cT = $(event.currentTarget).parent();
    var entity_id = cT.parents('.kor_medium_frame').attr('id').split('_').pop();
    
    ImageQuickButtons.mark('mark', entity_id);
  
    cT.hide();
    cT.parents('.button_bar').find('img[data-name=target_hit]').parent().show();
    
    return(false);
  });
  
  $(document).on('click', ".kor_medium_frame .button_bar img[data-name=target_hit]", function(event) {
    var cT = $(event.currentTarget).parent();
    var entity_id = cT.parents('.kor_medium_frame').attr('id').split('_').pop();
    
    ImageQuickButtons.mark('unmark', entity_id);
  
    cT.hide();
    cT.parents('.button_bar').find('img[data-name=target]').parent().show();
    
    return(false);
  });
}

ImageQuickButtons.register_events();

var Menu = new Object();

Menu.setup = function() {
  $('.menu_toggle').click(function(event) {
    var link = $(event.currentTarget);
    var menu = link.parent().next().children().first();
    var folding = $(menu).is(':visible') ? 'collapse' : 'expand';
    var url = null;
    switch(menu.attr('id')) {
      case 'config_menu':
        url = '/config/menu';
        break;
      case 'groups_menu':
        url = '/tools/groups_menu';
        break;
      case 'input_menu':
        url = '/tools/input_menu';
        break;
    }
    $.get(url, {'folding': folding});
    $(menu).toggle();
    return false;
  });
  
  $('#new_entity_kind_id').change(function(event){
    var input = $('#new_entity_kind_id');
  
    if (input.val() != -1) {
      location.href = '/entities/new?kind_id=' + input.val();
    }
  });
}


var Panel = new Object();

Panel.setup = function() {
  $('.exception_log').click(function(event) {
    $(this).find('.backtrace').toggle();
  });
}

var Forms = new Object();

Forms.setup = function() {
  $('.disable_entity_naming').change(function(event){
    $("input[name='entity[name]'], input[name='entity[distinct_name]']").parents('.form_field').hide();
  });
  
  $('.enable_entity_naming').change(function(event){
    $("input[name='entity[name]'], input[name='entity[distinct_name]']").parents('.form_field').show();
  });
}

$(document).ready(function(event){
  Application.setup();
});
