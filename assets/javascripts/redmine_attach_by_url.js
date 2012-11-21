jQuery(document).ready(function($) {
  // move attachments-by-url-fieldset into the right place
  $('#attachments-by-url-fieldset')
    .appendTo($('#attachments_fields').closest('.box'));

  // check url handler
  $('#attachments-by-url')
    .on("keyup change click", ".attachment-by-url input.file-url", function(evt) {
      var regUrl = /^(https?:\/\/)([\w\.]+)\.([a-z]{2,6}\.?)(\/[\w\.]*)*\/?[\?]?(\w+=[^&]*&?)*$/
      var isBadUrl =  !(this.value == "" || regUrl.test(this.value));
      $(this).closest('.attachment-by-url').toggleClass('bad-url', isBadUrl);
    });

  // add new attachment handler
  $("#attachments-by-url-fieldset a.add_attachment").on("click", function(evt) {
    evt.stopPropagation();
    if ($('.attachment-by-url').length >= 10) return false;
    fileFieldCount++;
    var newAttach = $('.attachment-by-url').last().clone();
    newAttach.find('input.file-url').val('').change();
    newAttach.find('input.file-name').val('').change();
    newAttach.find('input.description').val('');
    newAttach.find('input.file-url').attr("name",
      "attachments_by_url[" + fileFieldCount + "][file-url]");
    newAttach.find('input.file-name').attr("name",
      "attachments_by_url[" + fileFieldCount + "][file-name]");
    newAttach.find('input.description').attr("name",
      "attachments_by_url[" + fileFieldCount + "][description]");
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
});
