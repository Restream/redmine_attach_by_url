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
    switch(state) {
      case "in_progress":
        $(attach).find('.button-delete,.button-attachment-download').hide();
        $(attach).find('.state-text,.button-cancel,.progress').show();
        $(attach).find('.file-url').attr("disabled", "disabled");
        break;
      case "queued":
        $(attach).find('.button-delete,.button-attachment-download,.progress').hide();
        $(attach).find('.state-text,.button-cancel').show();
        $(attach).find('.file-url').attr("disabled", "disabled");
        break;
      case "completed":
        $(attach).find('.button-attachment-download,.button-cancel,.progress').hide();
        $(attach).find('.button-delete,.state-text').show();
        $(attach).find('.file-url').attr("disabled", "disabled");
        break;
      case "failed":
        $(attach).find('.button-cancel').hide();
        $(attach).find('.state-text,.button-delete,.button-attachment-download,.progress').show();
        $(attach).find('.file-url').removeAttr("disabled");
        break;
      default:
        $(attach).find('.state-text,.button-cancel,.progress').hide();
        $(attach).find('.button-delete,.button-attachment-download').show();
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

  function checkAttachmentState(attach) {
    var attach_id = attach.find('input.id').val();

    $.ajax({
      url: '/attachments_by_url/' + attach_id + '/state',
      dataType: 'json',
      type: 'GET',
      data: { attachment_by_url: { id: attach_id } },
      success: function(data, textStatus, jqXHR) {
        attach.find("input.id").val(data["id"]);
        attach.find(".state-text").text(data["state_text"]);
        attach.data(data);

        // draw progress-line
        if (data["complete_bytes"] && data["total_bytes"]) {
          var w = (data["complete_bytes"] / data["total_bytes"]) * 100;
          attach.find(".progress-line").css("width", w + "%");
        }

        changeAttachByUrlState(attach, data["state"]);
      },
      error: function(data, textStatus, jqXHR) {
        attach.find(".state-text").text(textStatus);
        changeAttachByUrlState(attach, "failed");
      }
    });
  }

  // add new attachment handler
  $("#attachments-by-url-fieldset a.add_attachment").on("click", function(evt) {
    evt.stopPropagation();
    if ($('.attachment-by-url').length >= 10) return false;
    fileFieldCount++;

    var newAttach = $('.attachment-by-url').last().clone();

    newAttach.find('input.id,input.file-url,input.description').val('');

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
    if ($('.attachment-by-url').length > 1) {
      $(this).closest('.attachment-by-url').remove();
    }
    return false;
  });

  // start download attachment
  $('#attachments-by-url').on("click", ".attachment-by-url .button-attachment-download", function(evt) {

    evt.stopPropagation();

    var attach = $(this).closest('.attachment-by-url');
    var attach_url = attach.find('input.file-url').val();

    $.ajax({
      url: '/attachments_by_url',
      dataType: 'json',
      type: 'POST',
      data: { attachment_by_url: { url: attach_url } },
      success: function(data, textStatus, jqXHR) {
        attach.find("input.id").val(data["id"]);
        attach.find(".state-text").text(data["state_text"]);
        // TODO: draw progress-bar
        changeAttachByUrlState(attach, data["state"]);
      },
      error: function(data, textStatus, jqXHR) {
        attach.find(".state-text").text(textStatus);
        changeAttachByUrlState(attach, "failed");
      }
    });

    return false;
  });

  // cancel download attachment
  $('#attachments-by-url').on("click", ".attachment-by-url .button-cancel", function(evt) {

    evt.stopPropagation();

    var attach = $(this).closest('.attachment-by-url');
    var attach_id = attach.find('input.id').val();

    $.ajax({
      url: '/attachments_by_url/' + attach_id,
      dataType: 'json',
      type: 'DELETE',
      data: { attachment_by_url: { id: attach_id } },
      success: function(data, textStatus, jqXHR) {
        attach.find("input.id").val(data["id"]);
        attach.find(".state-text").text(data["state_text"]);
        changeAttachByUrlState(attach, data["state"]);
      },
      error: function(data, textStatus, jqXHR) {
        attach.find(".state-text").text(textStatus);
        changeAttachByUrlState(attach, "failed");
      }
    });

    return false;
  });
});
