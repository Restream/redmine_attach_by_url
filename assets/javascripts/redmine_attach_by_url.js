jQuery(document).ready(function($) {
  // move attachments-by-url-fieldset into the right place
  $('#attachments-by-url-fieldset')
    .appendTo($('#attachments_fields').closest('.box'));

  function cleanArray(actual){
    var newArray = new Array();
    for(var i = 0; i < actual.length; i++) {
      if (actual[i]) {
        newArray.push(actual[i]);
      }
    }
    return newArray;
  }

  function manageVisibilityByState(attach, state) {
    $(attach).find('.state-icon').hide();
    switch(state) {
      case "in_progress":
        $(attach).find('.state-text,.button-delete,.button-attachment-download,.dummy').hide();
        $(attach).find('.button-cancel,.progress,.state-icon.in_progress').show();
        $(attach).find('.file-url').attr("disabled", "disabled");
        break;
      case "queued":
        $(attach).find('.state-text,.button-delete,.button-attachment-download,.progress,.dummy').hide();
        $(attach).find('.button-cancel,.state-icon.queued').show();
        $(attach).find('.file-url').attr("disabled", "disabled");
        break;
      case "completed":
        $(attach).find('.state-text,.button-attachment-download,.button-cancel,.progress').hide();
        $(attach).find('.button-delete,.state-icon.completed,.dummy').show();
        $(attach).find('.file-url').attr("disabled", "disabled");
        break;
      case "failed":
        $(attach).find('.button-cancel,.progress,.dummy').hide();
        $(attach).find('.state-text,.button-delete,.button-attachment-download,.state-icon.failed').show();
        $(attach).find('.file-url').removeAttr("disabled");
        break;
      default:
        $(attach).find('.state-text,.button-cancel,.progress,.dummy').hide();
        $(attach).find('.button-delete,.button-attachment-download,.state-icon.ready').show();
        $(attach).find('.file-url').removeAttr("disabled");
    }
  }

  function changeAttachByUrlState(attach, newState) {
    var newClass = cleanArray(["attachment-by-url", newState]).join(" ");
    $(attach).removeClass();
    $(attach).addClass(newClass);

    manageVisibilityByState(attach, newState);

    // continuously check the state every 500ms
    if (/queued|in_progress/.test(newState)) {
      setTimeout(function() {
        checkAttachmentState(attach);
      }, 500);
    }
  }

  function authAjax(attach, params) {
    params.data['authenticity_token'] = $('input[name=authenticity_token]').first().val();
    params.error = params.error || function(data, textStatus, jqXHR) {
      attach.find(".state-text").text(textStatus);
      changeAttachByUrlState(attach, "failed");
    };
    params.success = params.success || function(data, textStatus, jqXHR) {
      attach.find("input.id").val(data["id"]);
      attach.find(".state-text").text(data["state_text"]);
      attach.data(data);

      // draw progress-line
      if (data["complete_bytes"] && data["total_bytes"]) {
        var w = (data["complete_bytes"] / data["total_bytes"]) * 100;
        attach.find(".progress-line").css("width", w + "%");
      }

      changeAttachByUrlState(attach, data["state"]);
    };

    // don't show loading indicator
    attach.addClass('ajax-loading');
    params.complete = function(jqXHR, textStatus) {
      attach.removeClass('ajax-loading');
    };

    params.dataType = 'json';
    $.ajax(params);
  }

  function checkAttachmentState(attach) {
    var attach_id = attach.find('input.id').val();

    authAjax(attach, {
      url: '/attachments_by_url/' + attach_id + '/state',
      type: 'GET',
      data: { attachment_by_url: { id: attach_id } }
    });
  }

  // add new attachment handler
  $("#attachments-by-url-fieldset a.add_attachment").on("click", function(evt) {
    evt.stopPropagation();
    if ($('.attachment-by-url').length >= 10) return false;
    fileFieldCount++;

    var newAttach = $('.attachment-by-url').last().clone();

    newAttach.find('input.id,input.file-url,input.description').val('');
    newAttach.find('.progress-line').css("width", 0);

    newAttach.find('input.id').attr("name",
      "attachments_by_url[" + fileFieldCount + "][id]");
    newAttach.find('input.file-url').attr("name",
      "attachments_by_url[" + fileFieldCount + "][url]");
    newAttach.find('input.description').attr("name",
      "attachments_by_url[" + fileFieldCount + "][description]");

    changeAttachByUrlState(newAttach, null);

    newAttach.appendTo($('#attachments-by-url'));
    return false;
  });

  // remove attachment handler
  $('#attachments-by-url').on("click", ".button-delete", function(evt) {
    evt.stopPropagation();
    if ($('.attachment-by-url').length < 2) {
      $("#attachments-by-url-fieldset a.add_attachment").click();
    }
    $(this).closest('.attachment-by-url').remove();
    return false;
  });

  function downloadAttachByUrl(attach){
    var attach_url = attach.find('input.file-url').val();

    authAjax(attach, {
      url: '/attachments_by_url',
      type: 'POST',
      data: { attachment_by_url: { url: attach_url } }
    });
  }

  // start download attachment
  $('#attachments-by-url').on("click", ".attachment-by-url .button-attachment-download", function(evt) {

    evt.stopPropagation();

    var attach = $(this).closest('.attachment-by-url');
    downloadAttachByUrl(attach);

    return false;
  });

  // start downloading when url change
  $('#attachments-by-url')
    .on("input propertychange", ".attachment-by-url input.file-url", function(evt) {

      var attach = $(this).closest('.attachment-by-url');
      if (attach.is("queued,.in_progress,.failed,.canceled,.completed")) return;

      var regUrl = /^(https?:\/\/)([\w\.]+)\.([a-z]{2,6}\.?)(\/[\w\.]*)*\/?[\?]?(\w+=[^&]*&?)*$/
      if  (this.value != "" && regUrl.test(this.value)) {
        downloadAttachByUrl(attach);
      }
    });

  // cancel download attachment
  $('#attachments-by-url').on("click", ".attachment-by-url .button-cancel", function(evt) {

    evt.stopPropagation();

    var attach = $(this).closest('.attachment-by-url');
    var attach_id = attach.find('input.id').val();

    authAjax(attach, {
      url: '/attachments_by_url/' + attach_id,
      type: 'DELETE',
      data: { attachment_by_url: { id: attach_id } }
    });

    return false;
  });
});
