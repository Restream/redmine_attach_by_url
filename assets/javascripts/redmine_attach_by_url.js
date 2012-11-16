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
    newAttach.find('input.description').val('');
    newAttach.find('input.file-url').attr("name", "attachments[" + fileFieldCount + "][file-url]");
    newAttach.find('input.file-by-url').attr("name", "attachments[" + fileFieldCount + "][file]");
    newAttach.find('input.description').attr("name", "attachments[" + fileFieldCount + "][description]");
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

  // download attachment handler
  $('#attachments-by-url').on("click", ".button-download", function(evt) {
    evt.stopPropagation();

    var attach = $(this).closest('.attachment-by-url');
    var xhr = new XMLHttpRequest();
    var url = attach.find('input.file-url').val();
    // var url = 'http://img22.ria.ru/images/91049/95/910499535.jpg';

    if(xhr) {

      // attach.find('.input-file-url-block').hide();
      // attach.find('.download-progress-block').show();

      xhr.open('GET', url, true);
      xhr.responseType = "blob";

      // var eventSource = xhr.upload || xhr;
      // var progressBar = attach.find('progress');

      // eventSource.addEventListener("progress", function(e) {
      //     // normalize position attributes across XMLHttpRequest versions and browsers
      //     var position = e.position || e.loaded;
      //     var total = e.totalSize || e.total;

      //     progressBar.attr("max", total);
      //     progressBar.attr("value", position);
      // });

      xhr.onreadystatechange = function () {
        if (xhr.readyState == xhr.DONE) {
          var img = document.createElement('img');
          var urlApi = window.webkitURL ? webkitURL : URL;
          img.onload = function(e) {
            urlApi.revokeObjectURL(img.src); // Clean up after yourself.
          };
          var blob = xhr.reponse;
          var fd = FormData(attach.closest('form')[0]);
          fd.append('attachments[10][file]', blob);
          // img.src = urlApi.createObjectURL(xblob);
          // var fields = $('attachments_fields');
          // attach.appendChild(img);

          // attach.find('.download-progress-block').hide();
          // attach.find('.done-block').show();
        }
      };

      xhr.send();
    }

    return false;
  });



});

function downloadByUrl(el) {

  var xhr = new XMLHttpRequest();
  // var url = $(el).previous('input').getValue();
  var url = 'http://img22.ria.ru/images/91049/95/910499535.jpg';

  if(xhr) {
    xhr.open('GET', url, true);
    xhr.responseType = "blob";
    xhr.onreadystatechange = function () {
      if (xhr.readyState == xhr.DONE) {
        var img = document.createElement('img');
        var urlApi = window.webkitURL ? webkitURL : URL;
        img.onload = function(e) {
          urlApi.revokeObjectURL(img.src); // Clean up after yourself.
        };
        xblob = xhr.reponse;
        img.src = urlApi.createObjectURL(xblob);
        var fields = $('attachments_fields');
        fields.appendChild(img);
      }
    };
    xhr.send();
  }
}
