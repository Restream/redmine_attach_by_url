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

  function changeAttachByUrlState(attach, newState) {
    var newClass = cleanArray([".attachment-by-url.", newState]).join(".");
    $(attach).css("class", newClass)
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

    changeAttachByUrlState(newAttach, "ready");

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

  // start download attchment
  $('#attachments-by-url').on("click", ".attachment-by-url .button-attachment-download", function(evt) {

    evt.stopPropagation();
    changeAttachByUrlState($(this).closest('.attachment-by-url'), "in-progress");

    // TODO: call attchments_by_url#create

    return false;
  });

  // cancel download attchment
  $('#attachments-by-url').on("click", ".attachment-by-url.in-progress .button-cancel", function(evt) {

    evt.stopPropagation();
    changeAttachByUrlState($(this).closest('.attachment-by-url'), null);

    // TODO: call attchments_by_url#cancel

    return false;
  });
});
