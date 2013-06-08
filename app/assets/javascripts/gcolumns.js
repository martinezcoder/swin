jQuery(function ($) {
  // Load Google visualization library if a chart element exists
  if ($('[data-column-chart]').length > 0) {
    $.getScript('https://www.google.com/jsapi', function (data, textStatus) {
      google.load('visualization', '1.0', { 'packages': ['corechart'], 'callback': function () {
        // Google visualization library loaded
        $('[data-column-chart]').each(function () {
          var div = $(this)
          // Fetch chart data	
          $.getJSON(div.data('column-chart'), function (jsonData) {
            // Create DataTable from received chart data
	            
		      // Create our data table out of JSON data loaded from server.
		      var data = new google.visualization.DataTable(jsonData);
		
		      // Instantiate and draw our chart, passing in some options.
		      var chart = new google.visualization.ComboChart(document.getElementById('chart_div2'));
		      
		      chart.draw(data, jsonData.options);
		  
          });
        });
      }});
    });
  }
});

