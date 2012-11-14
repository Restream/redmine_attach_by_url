//TODO: add handlers to these classes download, delete, add_attachment-by-url

jQuery(document).ready(function($) {
  // move attachments-by-url-fieldset into the right place
  $('#attachments-by-url-fieldset')
    .appendTo($('#attachments_fields').closest('.box'));

  // add check url handler
  $('#attachments-by-url')
    .on("keyup change click", ".attachment-by-url input.file-url", function(evt) {
      setTimeout
      var regUrl = /^(https?:\/\/)([\w\.]+)\.([a-z]{2,6}\.?)(\/[\w\.]*)*\/?[\?]?(\w+=[^&]*&?)*$/
      var isBadUrl =  !(this.value == "" || regUrl.test(this.value));
      $(this).closest('.attachment-by-url').toggleClass('bad-url', isBadUrl);
    });
});

function addFileByUrlField(blob) {
  var fields = $('attachments-by-url_fields');
  if (fields.childElements().length >= 10) return false;
  fileFieldCount++;
  var s = new Element('div');
  s.update(fields.down('div').innerHTML);

  var fileUrl = s.down('input.file-url');
  fileUrl.name = "attachments[" + fileFieldCount + "][file-url]";
  fileUrl.value = "";
  bindHandlerToFileUrlChange(fileUrl);

  s.down('input.file_by_url').name = "attachments[" + fileFieldCount + "][file]";
  s.down('input.description').name = "attachments[" + fileFieldCount + "][description]";
  fields.appendChild(s);
}

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
