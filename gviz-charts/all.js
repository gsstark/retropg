// Load the Visualization API
//google.charts.load('current', {'packages':['line']});
google.charts.load('current', {'packages':['corechart']});

// Set a callback to run when the Google Visualization API is loaded.
google.charts.setOnLoadCallback(drawSheetName);


var options = {
    title: '20 years of building Postgres',
    interpolateNulls: true,
    //	width: 800,
    //  height: 600,
    titleTextStyle: {fontName: 'Arial', fontSize: 24, bold: true, italic: false},
    legend: {
		position: 'top',
		textStyle: {fontSize: 18},
		maxLines: 2
    },
    hAxis: { 
		title: 'GIT Commit Date',
		gridlines: { count: 20, color: '#a0a0a0'},
		minorGridlines: {count: 11, color: '#d0d0d0'},
		format:'yyyy',
		textStyle: {fontName: 'Arial', fontSize: 24, bold: true, italic: false},
		titleTextStyle: {fontName: 'Arial', fontSize: 24, bold: true, italic: false},
    },
    vAxis: {
		title: 'Build Time (seconds)',
		gridlines: { count: 20, color: '#a0a0a0' },
		format: "#,###s",
		minorGridlines: {count: 10, color: '#d0d0d0'},
		logScale: true,
		textStyle: {fontName: 'Arial', fontSize: 24, bold: true, italic: false},
		titleTextStyle: {fontName: 'Arial', fontSize: 24, bold: true, italic: false},
    },
    chartArea: {
		left:'10%',
		top:'10%',
		width:'85%',
		height:'80%'
    },
	//    series: {
	//	7: {lineWidth: 0, visibleInLegend: false, annotations: {stem: {length: 0}, style: 'line'}},
	//	8: {lineWidth: 0, visibleInLegend: false, annotations: {style: 'point'}},
	//    },
    annotations: {
		//style: 'line',
		// datum: { color: "black", style: "line"},
		// stem: { color: 'black', length: 20 },

		datum: {stem: {color: 'black', length: 40}},
		textStyle: {
			fontName: 'Arial',
			fontSize: 24,
			bold: true,
			italic: false,
			// The color of the text.
			color: 'black',
			// The color of the text outline.
			//auraColor: '#d799ae',
			// The transparency of the text.
			opacity: 1
		},
		//	boxStyle: {
		//	    // Color of the box outline.
		//	    //stroke: '#888',
		//	    // Thickness of the box outline.
		//	    //strokeWidth: 1,
		//	    // x-radius of the corner curvature.
		//	    rx: 5,
		//	    // y-radius of the corner curvature.
		//	    ry: 5,
		//	    // Attributes for linear gradient fill.
		//	    gradient: {
		//		// Start color for gradient.
		//		color1: '#ffffa0',
		//		// Finish color for gradient.
		//		color2: '#ffc0c0',
		//		// Where on the boundary to start and
		//		// end the color1/color2 gradient,
		//		// relative to the upper left corner
		//		// of the boundary.
		//		x1: '0%', y1: '0%',
		//		x2: '100%', y2: '100%',
		//		// If true, the boundary for x1,
		//		// y1, x2, and y2 is the box. If
		//		// false, it's the entire chart.
		//		useObjectBoundingBoxUnits: true
		//	    }
		//	}
    },
};

var data, release_notes, data, chart;

function drawSheetName() {
    var queryString = encodeURIComponent('SELECT A, C'+
										 'label '+
										 'C "Build Time (seconds)",'+
										 ''
										);
    var query = new google.visualization.Query(
		'https://docs.google.com/spreadsheets/d/1cedmLGmvWfUT3ihk5FpNW47cNouCA_Vq5n8mT3c6qhY/gviz/tq?sheet=Build+Time&headers=1&tq=' + queryString);
    query.send(handleSampleDataQueryResponse);
}

function handleSampleDataQueryResponse(response) {
    if (response.isError()) {
		alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
		return;
    }
    data = response.getDataTable();

    // Create the data table.
    release_notes = new google.visualization.DataTable();
    release_notes.addColumn('date', 'Date');
    release_notes.addColumn('string', 'Tag');
    release_notes.addColumn('number', 'release', 'XX');
    release_notes.addColumn({type: 'string',
							 label: 'Note',
							 role:'annotation',
							 id: 'X'
							});
    release_notes.addRows([
		[new Date(2001,04,05),'REL7_1_3', 180, '7.1'],
		[new Date(2002,10,04),'REL7_3_21', 180, '7.3'],
		[new Date(2003,10,03),'REL7_4_30', 180, '7.4'],
		[new Date(2005,00,17),'REL8_0_26', 180, '8.0'],
		[new Date(2005,10,05),'REL8_1_23', 180, '8.1'],
		[new Date(2006,11,02),'REL8_2_23', 180, '8.2'],
		[new Date(2008,01,12),'REL8_3_23', 180, '8.3'],
		[new Date(2009,05,27),'REL8_4_22', 180, '8.4'],
		[new Date(2010,06,09),'REL9_0_23', 180, '9.0'],
		[new Date(2011,05,11),'REL9_1_19', 180, '9.1'],
		[new Date(2012,01,15),'REL9_2_14', 180, '9.2'],
		[new Date(2013,05,14),'REL9_3_10', 180, '9.3'],
		[new Date(2014,05,10),'REL9_4_5', 180, '9.4'],
		[new Date(2015,00,16),'REL9_5_0', 180, '9.5'],
    ]);

    merged_data = google.visualization.data.join(data, release_notes, 'left', [[0,0]], [1,2,3,4,5,6,7], [2,3]);

    chart = new google.visualization.LineChart(document.getElementById('build_div'));
    chart.draw(merged_data, options);
}

