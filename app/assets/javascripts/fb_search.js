
jQuery(function ($) {

  if ($('[data-facebook-search]').length > 0) {
	          
      var fbSearchDiv = $('[data-facebook-search]');
      var valor = fbSearchDiv.data('facebook-search');

	  var searching=valor.indexOf("search");

	  if (searching < 0) {
	  	fbSearchDiv.html("<br>esto es una URL</br>" + valor);

	  	$.getJSON(valor, function (jsonData) {
	  		fbSearchDiv.html(jsonData.name);
	  		fbSearchDiv.append("<img src='https://graph.facebook.com/" + jsonData.id + "/picture'></img>");
        });
          	  		
	  }
	  else
	  {

          $.getJSON(fbSearchDiv.data('facebook-search'), function (jsonData) {

			fbSearchDiv.html("");
          	$.each(jsonData.data, function(i, item){

				fbSearchDiv.append(item.name);
				fbSearchDiv.append(":");
				fbSearchDiv.append("<img src='https://graph.facebook.com/" + item.id + "/picture'></img>");
				fbSearchDiv.append(":");

          	});
          	
          	//div.html(search_result);
          	
          	//var jdata = JSON.stringify(jsonData.data);
          	//div.html(jdata);
          	           	
          });

	  }

  }

});

