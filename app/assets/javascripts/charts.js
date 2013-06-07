jQuery(function ($) {
  // Load Google visualization library if a chart element exists
  if ($('[data-query-chart]').length > 0) {
    $.getScript('https://www.google.com/jsapi', function (data, textStatus) {
      google.load('visualization', '1.0', { 'packages': ['corechart'], 'callback': function () {
        // Google visualization library loaded
        $('[data-query-chart]').each(function () {
          var div = $(this)
          // Fetch chart data	
          $.getJSON(div.data('query-chart'), function (data) {
            // Create DataTable from received chart data
            var dataTable = new google.visualization.DataTable();
            $.each(data.cols, function () { dataTable.addColumn.apply(dataTable, this); });
            dataTable.addRows(data.rows);
            // Draw the chart
            var chart = new google.visualization.ChartWrapper();
            chart.setChartType(data.type);
            chart.setDataTable(dataTable);
            chart.setOptions(data.options);
            chart.setOption('width', div.width());
            chart.setOption('height', div.height());

			chart.draw(div.get(0));

			if ($('[data-query-table]').length > 0 ) {
	
	            // Draw the chart
	            $('[data-query-table]').each(function () {
	            	
					var div2 = $(this);
	
		            var table = new google.visualization.ChartWrapper();
		            table.setChartType('Table');
		            table.setDataTable(dataTable);
		            table.setOptions(data.options);
		            table.setOption('width', div.width());
		            table.setOption('height', div.height());
		
					table.draw(div2.get(0));
		
					google.visualization.events.addListener(table, 'ready', onReadyTable);

					function onReadyTable() {
						google.visualization.events.addListener(table.getChart(), 'select', refreshChart);
					}

					function refreshChart() {
					  chart.getChart().setSelection(table.getChart().getSelection());
					}

				});
	
			}
		  
          });
        });
      }});
    });
  }
});
