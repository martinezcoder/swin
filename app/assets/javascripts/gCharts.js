jQuery(function ($) {
  // Load Google visualization library if a chart element exists
  if ($('[data-chart]').length > 0) {
    $.getScript('https://www.google.com/jsapi', function (data, textStatus) {
      google.load('visualization', '1.0', { 'packages': ['corechart'], 'callback': function () {
        // Google visualization library loaded
        $('[data-chart]').each(function () {
          var div = $(this)
          // Fetch chart data	
          $.getJSON(div.data('chart'), function (jsonData) {
            // Create DataTable from received chart data
	            
		
		      // Instantiate and draw our chart, passing in some options.
//		      var chart = new google.visualization.ComboChart(document.getElementById('chart_div2'));
		      var chart = new google.visualization.ComboChart(document.getElementById(jsonData.divId));
		      
//		      chart.draw(data, jsonData.options);

		      // Create our data table out of JSON data loaded from server.
		      var dataA = new google.visualization.DataTable(jsonData);
			  var dataChartA = new google.visualization.DataView(dataA);
		 	  dataChartA.setColumns([1,0]);
			  chart.draw(dataChartA, jsonData.options);

		      var data = new google.visualization.DataTable(jsonData);
			  var dataChart = new google.visualization.DataView(data);
		 	  dataChart.setColumns(jsonData.graphShowCols);
			  chart.draw(dataChart, jsonData.options);
	  
          });
        });
      }});
    });
  }
});

