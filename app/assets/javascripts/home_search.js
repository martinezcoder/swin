
jQuery(function ($) {

  if ($('[data-facebook-search]').length > 0) {

          var div = document.getElementById("home_search");
          var valor = div.getAttribute('data-facebook-search');
          
		  var n=valor.search("http://"); 
		  //$("#home_search").html(n);
		  
		  if (n > 0) {
		  	div.html(valor);
		  }
		  else
		  {
	          var div = $('[data-facebook-search]')
	
	
	          $.getJSON(div.data('facebook-search'), function (jsonData) {
	          	var jdata = JSON.stringify(jsonData);
	          	div.html(jdata);          	
	          });	
		  }

  }

});

