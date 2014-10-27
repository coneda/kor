/* Application */

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

Application.alter_comment_links = function() {
  $('span.text > p a').attr('target', '_blank');
}

Application.setup_kor_command_image_events = function() {
  var images = $('img.kor_command_image');

  images.mouseover(function(event) {
    var image = $(event.currentTarget);
    var new_src = image.attr('src').replace('.gif', '_over.gif');
    image.attr('src', new_src);
  });
  
  images.mouseout(function(event) {
    var image = $(event.currentTarget);
    var new_src = image.attr('src').replace('_over.gif', '.gif');
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
  $(document).on('click', 'a.popup', function(e) { 
    window.open($(this).attr('href')); 
    e.preventDefault(); 
  });
  
  $('#templates .dialog_popup').dialog({autoOpen: false, width: 200});
  $(document).on('click', 'a.dialog_popup', function(event){
    var id = $(this).attr('id');
    $('.dialog_popup.' + id).dialog('open');
    return false;
  });
}

Application.setup_ajax = function() {
  $.ajaxSetup({
    beforeSend: function(xhr) {
      xhr.setRequestHeader('Accept', 'text/javascript');
      Kor.ajax_loading();
    },
    complete: function(xhr) {
      Kor.ajax_not_loading();
    }
  });
}

Application.load_core_extensions = function() {
  String.prototype.capitalize_first_letter = function() {
    return this.charAt(0).toUpperCase() + this.substr(1);
  }
}

Application.render_engagement = function(e) {
  var stamp = e.created_at.replace(/:\d\d\+\d\d:\d\d/, '').replace(/T/, ' ');
  return "<li>" + e.credits + " - " + e.kind + " - " + stamp + "</li>";
}

Application.setup_user_credits = function() {
  $('.user_credit_list').on('click', '.user a', function(event){
    var user = $(this).parents('.user');
    
    if (user.data('expanded') != 'yes') {
      var user_id = user.attr('data-user-id');
      window.current_details = user.find('ul.details');
      
      $.ajax({
        url: '/tools/credits/' + user_id,
        success: function(data) {
          $(data).each(function(i, e){
            window.current_details.append(Application.render_engagement(e.engagement));
          });
          
          window.current_details.parents('.user').data('expanded', 'yes');
        }
      });

    } else {
      user.find('ul.details').empty();
      user.data('expanded', 'no');
    }
    
    return false;
  })
}

Application.setup = function() {
  Kor.setup_blaze();

  Application.load_core_extensions();
  Kor.load_settings();
  Application.setup_ajax();
  
  this.alter_comment_links();
  this.setup_kor_command_image_events();
  Kor.register_session_events();
  Kor.setup_help();
  Menu.setup();
  Panel.setup();
  Forms.setup();
  Kor.tagging.setup();
  this.setup_search_result_events();
  this.register_input_focus_events();
  this.focus_first_input();
  this.register_popups();
  this.setup_user_credits();

  $('table').attr('cellspacing', 0);
  
  Attachments.register_expert_search_events();
}

/* Kor */

Kor.setup_blaze = function() {
  $(document).on('click', 'a', function(event) {
    if (Settings.use_blaze) {
      var link = $(this);
      var url = link.attr('href');
      if (url.match(/^\/entities\/\d+$/)) {
        var parts = url.split("/");
        var id = parts[parts.length - 1]
        window.location.href = '/blaze/' + id;
        event.preventDefault();
        return false;
      }
    }
  });
}

Kor.load_settings = function() {
  Kor.options = Settings;
}

Kor.ajax_loading = function() {$('#ajax_loading_indicator').fadeIn(200);}
Kor.ajax_not_loading = function() {$('#ajax_loading_indicator').fadeOut(200);}

Kor.reverse_merge = function(given, defaults) {
  if (!given) {given = {};}
  if (!defaults) {defaults = {};}
  return $.extend(defaults, given);
}

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

Kor.config = function() {
  if (!this.settings) {
    this.settings = $.parseJSON($('#settings').val());
  }
  
  return this.settings;
}


Kor.cleanup_message_area = function() {
  $('#message_area').empty();
}

Kor.error = function(msg, options) {
  options = Kor.reverse_merge(options, {
    'field_name': null,
    'title': I18n.t('activerecord.errors.template.header').capitalize_first_letter()
  });
  
  var message_area = $('#message_area');
  var errors_div = message_area.find('.errors');
  
  if (errors_div.length == 0) {
    var tpl = KorTemplate.get('.errors');
    tpl.fill_in('.title', options.title);
    tpl.fill_in('.field_name', options.field_name);
    tpl.fill_in('span.message', msg);
    message_area.append(tpl);
  } else {
    var tpl = KorTemplate.get('.errors .error');
    tpl.fill_in('.field_name', options.field_name);
    tpl.fill_in('span.message', msg);
    errors_div.find('ul').append(tpl);
  }
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


/* Inplace tagging */

Kor.tagging = new Object();

Kor.tagging.split = function(value) {return value.split(/,\s*/);}
Kor.tagging.extractLast = function(term) {return Kor.tagging.split(term).pop();}

Kor.tagging.setup = function() {
  var url = '/kor/inplace/tags/entities/' + document.location.href.split('/').pop() + '/tags'

  $('.inplace').add('.inplace > span').editable(url, {
    onblur: 'submit',
    style: 'width: 250px; display: inline',
    type: 'autocomplete',
    tooltip: "Click to edit ...",
    placeholder: "<span style='margin-right: -5px'></span>",
    data: function(value, settings) {return "";},
    event: 'inplace',
    callback: function() {$(this).parent().find('a').show();},
    onreset: function() {$(this).parents('.inplace_container').find('a').show();}
  });
  
  $('.inplace').parent().find('a').click(function(event){
    $(event.currentTarget).hide();
    $(event.currentTarget).parent().find('.inplace').trigger('inplace');
    return false;
  });
}

$.editable.addInputType('autocomplete', {
  element: function(settings, original) {
    var input = $('<input type="text">');
    
    input.keydown(function(event){
      if (event.keyCode === $.ui.keyCode.TAB && $(this).data('autocomplete').menu.active) {
        event.preventDefault();
      }
    });
    
    input.autocomplete({
      source: function(request, response) {
        $.getJSON('/tags', {term: Kor.tagging.extractLast(request.term)}, response);
      },
      search: function() {
        var term = Kor.tagging.extractLast(this.value);
        if (term.length < 2) {
          return false;
        }
      },
      focus: function() {return false;},
      select: function(event, ui) {
        var terms = Kor.tagging.split(this.value);
        terms.pop();
        terms.push(ui.item.value);
        terms.push(' ');
        this.value = terms.join(", ");
        return false;
      }
    });
    
    $(this).append(input);
    
    return(input);
  }
});


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

  $(document).on('click', ".kor_medium_frame .button_bar img[alt=Target]", function(event) {
    var cT = $(event.currentTarget).parent();
    var entity_id = cT.parents('.kor_medium_frame').attr('id').split('_').pop();
    
    ImageQuickButtons.mark('mark', entity_id);
  
    cT.hide();
    cT.parents('.button_bar').find('img[alt=Target_hit]').parent().show();
    
    return(false);
  });
  
  $(document).on('click', ".kor_medium_frame .button_bar img[alt=Target_hit]", function(event) {
    var cT = $(event.currentTarget).parent();
    var entity_id = cT.parents('.kor_medium_frame').attr('id').split('_').pop();
    
    ImageQuickButtons.mark('unmark', entity_id);
  
    cT.hide();
    cT.parents('.button_bar').find('img[alt=Target]').parent().show();
    
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
  $(document).on('click', '.relation_toggle', function(event){
    var relation = $(this).parents('div.relation');
    force = !Panel.toggle_custom_state(relation, 'images_shown');
    relation.find('div.relationship').each( function(i, e){
      Panel.toggle_relationship_panel($(e), force);
    });

    Panel.toggle_image(
      relation.find('div.relation_switch img'),
      '/assets/triangle_up.gif', 
      '/assets/triangle_down.gif'
    );
    
    return false;
  });
  
  $(document).on('click', '.relationship_toggle', function(event){
    var relationship = $(this).parents('div.relationship');
    Panel.toggle_relationship_panel(relationship);
    return false;
  });
  
  $('.exception_log').click(function(event) {
    $(this).find('.backtrace').toggle();
  });
}

Panel.toggle_custom_state = function(element, state_property) {
  if (element.data(state_property) == null) {
    element.data(state_property, 'no');
  }

  if (element.data(state_property) == 'yes') {
    element.data(state_property, 'no');
    return true;
  } else {
    element.data(state_property, 'yes');
    return false;
  }
}

Panel.toggle_relationship_panel = function(relationship, force) {
  try {
    Panel.toggle_image(relationship.find('span.relationship_switch img'),
      '/assets/triangle_up.gif', '/assets/triangle_down.gif', force);

    var panel = relationship.find('div.switched_panel');
    if (force == null)
      panel.toggle();
    else if (force)
      panel.show();
    else
      panel.hide();

  } catch (error) {
    // no relation_switch found => no images
  }
}

Panel.reset_custom_state = function(element, state_property) {
  element.data(state_property, 'no');
}

Panel.reset_image = function(image, path) {
  image.attr('src', path);
}

Panel.reset_images_shown = function(element) {
  Panel.reset_custom_state(element, 'images_shown');
  Panel.reset_image(element.find('div.relation_switch img'), '/assets/triangle_up.gif');
}

Panel.toggle_image = function(image, path_1, path_2, force) {
  if (force == null) {
    if (image.attr('src').search(path_1) == -1) {
      image.attr('src', path_1);
    } else {
      image.attr('src', path_2);
    }
  } else if (force) {
    image.attr('src', path_2);
  } else {
    image.attr('src', path_1);
  }
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


///* switches the section_panels */
//function switch_section_panel(panel) {
//  subtitle = panel.down('.type');
//  if (subtitle)
//    subtitle.toggle();

//  content = panel.down('.content');
//  if (content)
//    content.toggle();

//  toggle_image(panel.down('.switch').down('img'), 
//    '/images/triangle_up.gif', '/images/triangle_down.gif' );
//}

$(document).ready(function(event){
  Application.setup();
});
