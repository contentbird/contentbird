var uploadifyForm = function(formSelector, fileName, signUrl, transport, doneLinkUrl, storageName, messages) {
  messages = JSON.parse(messages);

  var displayError = function(message){
    $(formSelector + ' .successMsg').hide();
    $(formSelector + ' .loading').hide();
    $(formSelector + ' progress').hide();
    $(formSelector + ' .errorMsg').html(message).show();
    $(formSelector + ' .fileinput-button').show();
    $(formSelector + ' .filesSize').show();
  };

  var displayUpload = function(){
    $(formSelector + ' .errorMsg').hide();
    $(formSelector + ' .successMsg').hide();
    $(formSelector + ' progress').show();
    $(formSelector + ' .loading').show();
    $(formSelector + ' .fileinput-button').hide ();
    $(formSelector + ' .filesSize').hide();
  };

  var displayProgress = function(progress){
    $(formSelector + ' progress > span').html(progress.toString()+' %');
    $(formSelector + ' progress').attr('value', progress.toString());
  };

  var displaySuccess = function(){
    $(formSelector + ' .loading').hide();
    $(formSelector + ' progress').hide();
    $(formSelector + ' .successMsg').html(messages['success'] + '<a href="'+ doneLinkUrl +'">'+ messages['doneLinkLabel'] + '</a>').show();
    $(formSelector + ' .fileinput-button > span').html('Ajouter un autre photo');
    $(formSelector + ' .fileinput-button').show();
    $(formSelector + ' .filesSize').show();
  };

  $(formSelector).fileupload({
    forceIframeTransport: (transport === 'iframe'),
    autoUpload: true,
    add: function (event, data) {
      var file = data.files[0]
      var fileExt = file.name.split('.').pop();
      if (!fileExt.match(/(?:jpg|jpeg|png|gif)$/i)) {
        displayError(messages['typeError']);
        return false
      }
      var ajaxParams = {
        url: signUrl,
        type: 'POST',
        dataType: 'json',
        data: {doc: {title: fileName, extension: fileExt}, storage_name: storageName, transport: transport},
        async: false,
        success: function(retdata) {
          $(formSelector).find('input[name=key]').val(retdata.key);
          $(formSelector).find('input[name=policy]').val(retdata.policy);
          $(formSelector).find('input[name=signature]').val(retdata.signature);
          $(formSelector).find('input[name=Content-Type]').val(file.type);
          if (transport==='iframe') {
            $(formSelector).find('input[name=success_action_redirect]').val(retdata.success_action_redirect);
          }
        }
      };

      if (transport==='iframe') {
        ajaxParams['timeout'] = 60000;
      }

    	$.ajax(ajaxParams);

      data.submit();
    },
    send: function(e, data) {
      displayUpload();
    },
    progress: function (e, data) {
        var progress = parseInt(data.loaded / data.total * 100, 10);
        displayProgress(progress);
    },
    fail: function(e, data) {
      displayError(messages['uploadError']);
    },
    done: function (event, data) {
      postUpload($(formSelector).find('input[name=key]').val(),
        function(){
          displaySuccess();
        },
        function(err){
          displayError(messages['postUploadError']);
        }
      );
    }
  });
}