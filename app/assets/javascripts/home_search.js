
jQuery(function ($) {

  if ($('[data-facebook-search]').length > 0) {

          var div = $('[data-facebook-search]')
          $.getJSON(div.data('facebook-search'), function (jsonData) {
          	var jdata = JSON.stringify(jsonData);
          	div.html(jdata);          	
          });	
  }

});

