function fbPage(id, name) {
	var txt  = "<li>";
		txt += 		"<div>";
  		txt += 			"<img class='fb_img' src='https://graph.facebook.com/" + id + "/picture' />";
  		txt += 					"<div class='name'><p>" + name +"</p></div>";
		txt += 			"<a href='/facebook/fb-" + id + "'>" ;
		txt +=				"<div class='arrow'></div>"	;
		txt += 			"</a>";  			
		txt += 		"</div>";
		txt += "</li>";
  	return txt;
}


jQuery(function ($) {

  if ($('[data-facebook-search]').length > 0) {   
      var fbSearchDiv = $('[data-facebook-search]');
      var valor = fbSearchDiv.data('facebook-search');
	  var searching=valor.indexOf("search");
 	  var htmlResult = "<ul>";
	
	  if (searching < 0) {
		    $.ajax({
		    	url: valor,
		    	async: false,
		    	dataType: 'json',
		    	success: function(jsonData) {
		    		htmlResult += fbPage(jsonData.id, jsonData.name);
		    	}
		    });
	  }
	  else {
	  	
	    $.ajax({
	    	url: fbSearchDiv.data('facebook-search'),
	    	async: false,
	    	dataType: 'json',
	    	success: function(jsonData) {
	          	$.each(jsonData.data, function(i, item){
					htmlResult += fbPage(item.id, item.name);
					if (i == 3) { return false;}
	          	});
	    	}
	    });
	    
	  }
	  htmlResult += "</ul>";
	  fbSearchDiv.html(htmlResult); 

  }

});

