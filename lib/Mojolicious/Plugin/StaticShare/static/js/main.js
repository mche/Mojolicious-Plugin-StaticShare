$( document ).ready(function() {
  $('#fileupload input').fileupload({
    dataType: 'json',
    //singleFileUploads: false,
    ////formData: function(){ return filenames; },
    add: function (e, data) {
      //~ console.log("add", data);
      var tbody = $('#fileupload').closest('.col').find('table.files tbody');
      var namefield = $('<input type="text" style="width:100%; display:block;" >');
      data.files.map(function (file, idx) {
        //~ console.log("add "+file.name);
        $('<tr class="orange-text text-darken-1">')
          .append($('<td class="name">')
            .append(namefield.val(file.name).change(function(event){  }))//file.name = $(this).val();
            .append($('<div class="red-text error">'))
          )
          .append($('<td class="action">')
            .append($('<a href="javascript:">')
              .append($('<svg class="icon icon15 orange-fill fill-darken-1"><use xlink:href="#svg:upload" />'))
              .click(function () {
                data.context = namefield;
                namefield.siblings('.error').html('');
                data.submit();
              })
            )
          )
          .append($('<td class="size right-align">').html(file.size))
          .append($('<td class="mtime right-align">').html((file.lastModified && new Date(file.lastModified).toLocaleString()) || (file.lastModifiedDate && file.lastModifiedDate.toLocaleString()) || ''))//
          .prependTo(tbody);
      });
    },
    progressall: function (e, data) {
        var progress = parseInt(data.loaded / data.total * 100, 10);
        $('#fileupload .determinate').css('width',  progress + '%');
    },
    done: function (e, data) {
      if(data.result.error) return data.context.siblings('.error').html(data.result.error);
      var name = data.context.val();
      var tr = data.context.closest('tr').removeClass('orange-text');
      $('td.name', tr).empty().append($('<a class="green-text">').attr('href', data.result.ok).html(name));
      $('td.action', tr).empty().append($('<a>').attr('href', data.result.ok+'?attachment').append($('<svg class="icon icon15 green-fill"><use xlink:href="#svg:download" />')));
      console.log("Upload finished."+data.result.ok);
      $('#fileupload .determinate').css('width',  '0%');
    }
  }).bind('fileuploadsubmit', function (e, data) {
    data.formData = {};//files: JSON.stringify(data.files)
    data.files.map(function(file, idx){
      for (var key in file){
        data.formData[key] = file[key];
      }
      if(data.context && data.context.val) data.formData.name = data.context.val();
      
    });
    
    return true;
  });
  
});
