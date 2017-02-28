$('document').ready(function(){

	$(".ninja-btn, .panel-overlay, .panel li a").click( function() {
	  $(".ninja-btn, .panel-overlay, .panel").toggleClass("active");
	  /* Check panel overlay */
	  if ($(".panel-overlay").hasClass("active")) {
	    $(".panel-overlay").fadeIn();
	  } else {
	    $(".panel-overlay").fadeOut();
	  }
	}); 

	var lat;
	var lon;
	var map;
	var mapnik;
	var markers;
	var markerLat;
	var markerLon;
	var fromProjection;
	var toProjection;

	$('#show-municipalities').click(function(){
        $('#municipalities-popup').fadeIn();
        $('#show-municipalities').fadeOut();
    });

 	OpenLayers.Control.Click = new OpenLayers.Class(OpenLayers.Control, {                
        defaultHandlerOptions: {
            'single': true,
            'double': false,
            'pixelTolerance': 0,
            'stopSingle': false,
            'stopDouble': false
        },

        initialize: function(options) {
            this.handlerOptions = OpenLayers.Util.extend(
                {}, this.defaultHandlerOptions
            );
            OpenLayers.Control.prototype.initialize.apply(
                this, arguments
            ); 
            this.handler = new OpenLayers.Handler.Click(
                this, {
                    'click': this.trigger
                }, this.handlerOptions
            );
        }, 

        trigger: function(e) {
        	var point, transformedMarker;
        	var size = new OpenLayers.Size(48,64);
        	var offset = new OpenLayers.Pixel(-(size.w/2), -size.h);
        	var icon = new OpenLayers.Icon('/i/pin-green.png', size, offset);

			if (map != null) {
	        	point = map.getLonLatFromPixel(e.xy);
        		markers.clearMarkers(); // Clear markers first
        		markers.addMarker(new OpenLayers.Marker(new OpenLayers.LonLat(point.lon, point.lat),icon)); // New Location
        		transformedMarker = point.transform(fromProjection, toProjection); // Transform marker

        		markerLat = transformedMarker.lat.toFixed(6);
        		markerLon = transformedMarker.lon.toFixed(6);
        	}
        }

    });

    function create_map(){
	 	lat = 42.6258687;
	 	lon = 20.8911131;
	 	var zoom = 9;

	 	fromProjection = new OpenLayers.Projection("EPSG:900913"); // Transform from Spherical Mercator Projection
	 	toProjection = new OpenLayers.Projection("EPSG:4326"); // To from WGS 1984
	 	var position = new OpenLayers.LonLat(lon, lat).transform(toProjection, fromProjection);

	 	map = new OpenLayers.Map('map');

		mapnik = new OpenLayers.Layer.OSM();
	 	map.addLayer(mapnik);

	 	markers = new OpenLayers.Layer.Markers("Markers");
	 	map.addLayer(markers);

	 	map.setCenter(position, zoom);

	 	var click = new OpenLayers.Control.Click();
        map.addControl(click);
        click.activate();

	 	// map.events.register("click", map, function (e) {
	 	//     "use strict";
	 	//     var point, transformedMarker;
	 	//     point = map.getLonLatFromPixel(e.xy);
	 	//     markers.clearMarkers(); // Clear markers first
	 	//     markers.addMarker(new OpenLayers.Marker(new OpenLayers.LonLat(point.lon, point.lat),icon)); // New Location
	 	//     transformedMarker = point.transform(fromProjection, toProjection); // Transform marker

	 	//     markerLat = transformedMarker.lat.toFixed(6);
	 	//     markerLon = transformedMarker.lon.toFixed(6);
	 	// });
    }	

    function destroy_map(){
    	// markers.clearMarkers();
    	markers.destroy();
    	markers=null;
    	map.destroy();
    	map=null;
    }

    $('#show-fpmap').click(function(){

		$('#map').fadeIn();
		$('#gotoaround').fadeIn();
		$('#show-fpmap').fadeOut();

	 	if (map == null) {
	 		create_map();
	 	}
    });

    $('#gotoaround').click(function(){
    	websiteDomain = window.location.host;
    	if (markers != null && (markerLat != null && markerLon !=null)) {
			location.href = 'http://' + websiteDomain + '/report/new?latitude='+markerLat+';longitude='+markerLon;
		}
    });

    $('#municipalities-close').click(function(){
        $('#municipalities-popup').fadeOut();
        $('#show-fpmap').fadeIn();
        $('#show-municipalities').fadeIn();
        $('#map').fadeOut();
        $('#gotoaround').fadeOut();
        destroy_map();
    });
    
    $('.municipality').click(function(){
    	websiteDomain = window.location.host;

		var lat = this.getAttribute('data-lat');
		var lon = this.getAttribute('data-lon');

		window.location.href = 'http://' + websiteDomain + '/around?latitude='+lat+';longitude='+lon+'&zoom=1';
    });


    // $('#choose-municipality').selectbox();

	// var municipalitiesArray = {
	// 	"Municipality of Prishtina" : {
	// 		"en" : "Municipality of Pristina",
	// 		"sq" : "Komuna e Prishtinës",
	// 		"sr" : "Opština Priština" 
	// 	},
	// 	"Municipality of Decan" : {
	// 		"en" : "Municipality of Decan",
	// 		"sq" : "Komuna e Deçanit",
	// 		"sr" : "Opština Dečane" 
	// 	},
	// 	"Municipality of Prizren" : {
	// 		"en" : "Municipality of Prizren",
	// 		"sq" : "Komuna e Prizrenit",
	// 		"sr" : "Opština Prizren" 
	// 	},
	// 	"Municipality of Gjakova" : {
	// 		"en" : "Municipality of Gjakova",
	// 		"sq" : "Komuna e Gjakovës",
	// 		"sr" : "Opština Djakovic" 
	// 	},
	// 	"Municipality of Skenderaj" : {
	// 		"en" : "Municipality of Skenderaj",
	// 		"sq" : "Komuna e Skënderajit",
	// 		"sr" : "Opština Srbica" 
	// 	},
	// 	"Municipality of Glogovac" : {
	// 		"en" : "Municipality of Glogovac",
	// 		"sq" : "Komuna e Gllogocit",
	// 		"sr" : "Opština Glogovac" 
	// 	},
	// 	"Municipality of Stimlje" : {
	// 		"en" : "Municipality of Stimlje",
	// 		"sq" : "Komuna e Shtimes",
	// 		"sr" : "Opština Štimlje" 
	// 	},
	// 	"Municipality of Gjilan" : {
	// 		"en" : "Municipality of Gjilan",
	// 		"sq" : "Komuna e Gjilanit",
	// 		"sr" : "Opština Gnjilane" 
	// 	},
	// 	"Municipality of Shtrpce" : {
	// 		"en" : "Municipality of Shtrpce",
	// 		"sq" : "Komuna e Shtërpcë",
	// 		"sr" : "Opština Štrpce" 
	// 	},
	// 	"Municipality of Dragash" : {
	// 		"en" : "Municipality of Dragash",
	// 		"sq" : "Komuna e Dragashit",
	// 		"sr" : "Opština Dragaš" 
	// 	},
	// 	"Municipality of Suva Reka" : {
	// 		"en" : "Municipality of Suva Reka",
	// 		"sq" : "Komuna e Suharekës",
	// 		"sr" : "Opština Suva Reka" 
	// 	},
	// 	"Municipality of Istog" : {
	// 		"en" : "Municipality of Istog",
	// 		"sq" : "Komuna e Istogut",
	// 		"sr" : "Opština Istok" 
	// 	},
	// 	"Municipality of Ferizaj" : {
	// 		"en" : "Municipality of Ferizaj",
	// 		"sq" : "Komuna e Ferizajit",
	// 		"sr" : "Opština Uroševac" 
	// 	},
	// 	"Municipality of Kacanik" : {
	// 		"en" : "Municipality of Kacanik",
	// 		"sq" : "Komuna e Kaçanikut",
	// 		"sr" : "Opština Kačanik" 
	// 	},
	// 	"Municipality of Viti" : {
	// 		"en" : "Municipality of Viti",
	// 		"sq" : "Komuna e Vitisë",
	// 		"sr" : "Opština Vitina" 
	// 	},
	// 	"Municipality of Klina" : {
	// 		"en" : "Municipality of Klina",
	// 		"sq" : "Komuna e Klinës",
	// 		"sr" : "Opština Klina" 
	// 	},
	// 	"Municipality of Vushtrri" : {
	// 		"en" : "Municipality of Vushtrri",
	// 		"sq" : "Komuna e Vushtrrisë",
	// 		"sr" : "Opština Vučitrn" 
	// 	},
	// 	"Municipality of Fushe Kosove" : {
	// 		"en" : "Municipality of Fushe Kosove",
	// 		"sq" : "Komuna e Fushë Kosovës",
	// 		"sr" : "Opština Kosovo Polje" 
	// 	},
	// 	"Municipality of Zubin Potok" : {
	// 		"en" : "Municipality of Zubin Potok",
	// 		"sq" : "Komuna e Zubin Potokut",
	// 		"sr" : "Opština Zubin Potok" 
	// 	},
	// 	"Municipality of Kamenica" : {
	// 		"en" : "Municipality of Kamenica",
	// 		"sq" : "Komuna e Kamenicës",
	// 		"sr" : "Opština Kamenica" 
	// 	},
	// 	"Municipality of Zvecan" : {
	// 		"en" : "Municipality of Zvecan",
	// 		"sq" : "Komuna e Zveçanit",
	// 		"sr" : "Opština Zvečan" 
	// 	},
	// 	"Municipality of Mitrovica" : {
	// 		"en" : "Municipality of Mitrovica",
	// 		"sq" : "Komuna e Mitrovicës",
	// 		"sr" : "Opština Mitrovica" 
	// 	},
	// 	"Municipality of Malisheve" : {
	// 		"en" : "Municipality of Malisheve",
	// 		"sq" : "Komuna e Malishevës",
	// 		"sr" : "Opština Mališevo" 
	// 	},
	// 	"Municipality of Leposaviq" : {
	// 		"en" : "Municipality of Leposaviq",
	// 		"sq" : "Komuna e Leposaviqit",
	// 		"sr" : "Opština Leposavič" 
	// 	},
	// 	"Municipality of Hani i Elezit" : {
	// 		"en" : "Municipality of Hani i Elezit",
	// 		"sq" : "Komuna e Hanit të Elezit",
	// 		"sr" : "Opština Elez Han" 
	// 	},
	// 	"Municipality of Lipjan" : {
	// 		"en" : "Municipality of Lipjan",
	// 		"sq" : "Komuna e Lipjanit",
	// 		"sr" : "Opština Lipjan" 
	// 	},
	// 	"Municipality of Mamush" : {
	// 		"en" : "Municipality of Mamush",
	// 		"sq" : "Komuna e Mamushës",
	// 		"sr" : "Opština Mamuša" 
	// 	},
	// 	"Municipality of Novo Brdo" : {
	// 		"en" : "Municipality of Novo Brdo",
	// 		"sq" : "Komuna e Novobërdës",
	// 		"sr" : "Opština Novo Brdo" 
	// 	},
	// 	"Municipality of Junik" : {
	// 		"en" : "Municipality of Junik",
	// 		"sq" : "Komuna e Junikut",
	// 		"sr" : "Opština Junik" 
	// 	},
	// 	"Municipality of Obilic" : {
	// 		"en" : "Municipality of Obilic",
	// 		"sq" : "Komuna e Obilicit",
	// 		"sr" : "Opština Obilič" 
	// 	},
	// 	"Municipality of Klokot" : {
	// 		"en" : "Municipality of Klokot",
	// 		"sq" : "Komuna e Kllokotit",
	// 		"sr" : "Opština Klokot" 
	// 	},
	// 	"Municipality of Rahovec" : {
	// 		"en" : "Municipality of Rahovec",
	// 		"sq" : "Komuna e Rahovecit",
	// 		"sr" : "Opština Orahovac" 
	// 	},
	// 	"Municipality of Gracanice" : {
	// 		"en" : "Municipality of Gracanice",
	// 		"sq" : "Komuna e Graçanicës",
	// 		"sr" : "Opština Gračanica" 
	// 	},
	// 	"Municipality of Peja" : {
	// 		"en" : "Municipality of Peja",
	// 		"sq" : "Komuna e Pejës",
	// 		"sr" : "Opština Peč" 
	// 	},
	// 	"Municipality of Ranilug" : {
	// 		"en" : "Municipality of Ranilug",
	// 		"sq" : "Komuna e Ranillugut",
	// 		"sr" : "Opština Ranilug" 
	// 	},
	// 	"Municipality of Podujevo" : {
	// 		"en" : "Municipality of Podujevo",
	// 		"sq" : "Komuna e Podujevës",
	// 		"sr" : "Opština Podujevo" 
	// 	},
	// 	"Municipality of Partesh" : {
	// 		"en" : "Municipality of Partesh",
	// 		"sq" : "Komuna e Parteshit",
	// 		"sr" : "Opština Parteš" 
	// 	},
	// 	"Municipality of North Mitrovica" : {
	// 		"en" : "Municipality of North Mitrovica",
	// 		"sq" : "Komuna e Mitrovicës Veriore",
	// 		"sr" : "Opština Severna Mitrovica" 
	// 	}
	// };

	// var websiteDomain = window.location.host;
	// var domainparts = websiteDomain.split('.');
	// var subdomain = domainparts[0];

	// if (subdomain == 'sq' || subdomain == "sr") {
	// 	var bodiesInPage = document.getElementsByClassName("changeBodyName");
	// 	for(var i = 0; i < bodiesInPage.length; i++){
	// 		if (bodiesInPage[i].innerText in municipalitiesArray) {
	// 			if(subdomain == 'sq'){
	// 				bodiesInPage[i].innerText = municipalitiesArray[bodiesInPage[i].innerText]["sq"];
	// 			} else if (subdomain == 'sr'){
	// 				bodiesInPage[i].innerText = municipalitiesArray[bodiesInPage[i].innerText]["sr"];
	// 			}
	// 		}			
	// 	}
	// }

		// var map,vectorLayer,selectMarkerControl,selectedFeature;

  //       var zoom        =   8;

  //       var fromProjection = new OpenLayers.Projection("EPSG:4326");   // Transform from WGS 1984
  //       var toProjection   = new OpenLayers.Projection("EPSG:900913"); // to Spherical Mercator Projection

  //       var cntrposition       = new OpenLayers.LonLat(lon, lat).transform( fromProjection, toProjection);
  //       map = new OpenLayers.Map("map",{
  //           controls: 
  //           	[
  //                   new OpenLayers.Control.PanZoomBar(),                        
  //                   new OpenLayers.Control.LayerSwitcher({}),
  //                   new OpenLayers.Control.Permalink(),
  //                   new OpenLayers.Control.MousePosition({}),
  //                   new OpenLayers.Control.ScaleLine(),
  //                   new OpenLayers.Control.OverviewMap(),
  //               ]
  //       });
  //       var mapnik      = new OpenLayers.Layer.OSM("MAP");

  //       // map.addLayers([,markers]);
  //       map.addLayer(mapnik);
  //       map.setCenter(cntrposition, zoom);


  // var mousePositionControl = new ol.control.MousePosition({
  //         coordinateFormat: ol.coordinate.createStringXY(4),
  //         projection: 'EPSG:4326',
  //         // comment the following two lines to have the mouse position
  //         // be placed within the map.
  //         className: 'custom-mouse-position',
  //         target: document.getElementById('mouse-position'),
  //         undefinedHTML: '&nbsp;'
  //       });

 	// var map = new ol.Map({
 	//         controls: ol.control.defaults({
 	//           attributionOptions: /** @type {olx.control.AttributionOptions} */ ({
 	//             collapsible: false
 	//           })
 	//         }).extend([mousePositionControl]),
 	//         layers: [
 	//           new ol.layer.Tile({
 	//             source: new ol.source.OSM()
 	//           })
 	//         ],
 	//         target: 'map',
 	//         view: new ol.View({
 	//           center: [lat, lon],
 	//           zoom: 10
 	//         })
 	//       });

 	// var projectionSelect = document.getElementById('projection');
 	//       projectionSelect.addEventListener('change', function(event) {
 	//         mousePositionControl.setProjection(ol.proj.get(event.target.value));
 	//       });

 	//       var precisionInput = document.getElementById('precision');
 	//       precisionInput.addEventListener('change', function(event) {
 	//         var format = ol.coordinate.createStringXY(event.target.valueAsNumber);
 	//         mousePositionControl.setCoordinateFormat(format);
 	//       });


    

});

