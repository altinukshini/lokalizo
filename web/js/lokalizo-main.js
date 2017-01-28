var selectedCategories = new Array();


//FILTROS POR CATEGORIAS
function getCategoryGroups(){

var QueryString = function () {
  // This function is anonymous, is executed immediately and 
  // the return value is assigned to QueryString!
  var query_string = {};
  var query = window.location.search.substring(1);
  var vars = query.split(";");
  for (var i=0;i<vars.length;i++) {
    var pair = vars[i].split("=");
        // If first entry with this name
    if (typeof query_string[pair[0]] === "undefined") {
      query_string[pair[0]] = decodeURIComponent(pair[1]);
        // If second entry with this name
    } else if (typeof query_string[pair[0]] === "string") {
      var arr = [ query_string[pair[0]],decodeURIComponent(pair[1]) ];
      query_string[pair[0]] = arr;
        // If third or later entry with this name
    } else {
      query_string[pair[0]].push(decodeURIComponent(pair[1]));
    }
  } 
  return query_string;
}();

//	var latitude = "-34.906557";
//	var longitude = "-56.199769";

	var latitude = QueryString.latitude;
	var longitude = QueryString.longitude;

	$.getJSON( "/report/new/ajax?latitude="+latitude+"&longitude="+longitude+"&format=json", function( data ) {
		var categories = data.categories;
		$.each( categories, function( key, val ) {
			if(key!=-2){
				var name="";
				var icon = "./i/category/";
				var color = "";

				color = "red";
				icon = "./i/pin-red.png";
				name = val;

//				$.each( val, function( key2, val2 ) {
//					if(key2=="name"){
//						name = val2;
//					}
//					if(key2=="icon"){
//						icon = "./i/pin-red.png";//icon + val2 + ".png";
//					}
//					if(key2=="color"){
//						color = val2;
//					}
//				});
				var group_id = key;
				addCategoryFilter(name,group_id,icon, color);
			}
		});
	})
		.done(function() {
		})
		.fail(function() {
			console.log( "error" );
		})
		.always(function() {
			console.log( "complete" );
		});
}

function addCategoryFilter(name,group_id,icon,color){
		/*var html = "<div class='category_filter' id='category_filter_" + group_id + "' onclick='selectCategoryGroup(\""+group_id+"\")'>";
		html = html + "<img class='filter_icon' src='."+icon+"'/>";
		html = html + "<h3>" + name + "</h3>";
		html = html + "</div>";*/
		var html = "<div class='multi-select-container'>"
		var html = "<div style='background-color:red;' class='filter_category' value='"+name+"' for='filter_category_"+group_id+"' id='filter_category_" + group_id + "' onclick='selectCategoryGroup(\""+group_id+"\")'>";
		//html = html + "<img class='filter_icon' src='."+icon+"'/>";
		html = html + "<h4>" + name + "</h4>";
		html = html + "</div></div>";
		$("#categories-filters").append(html);
}

function selectCategoryGroup(id){
	if(!selectedCategories){
		selectedCategories = new Array();
	}
	var filter = document.getElementById("filter_category_"+id);
	/*if(filter.style.backgroundColor == "transparent" || filter.style.backgroundColor == ""){
		filter.style.backgroundColor = "#000000";
		selectedCategories.push(id);
	}else{
		filter.style.backgroundColor = "transparent";*/
	if($("#filter_category_"+id).attr("class") == "filter_category"){
		$("#filter_category_"+id).attr("class","filter_category_selected");
		selectedCategories.push(id);
	}else{
		$("#filter_category_"+id).attr("class","filter_category");
		var newList = new Array();
		selectedCategories.forEach(function(element,index,array){
			if(element!=id){
				newList.push(element);
			}
		});
		selectedCategories = newList;
	}
//	var strCats = selectedCategories.join(',');
//	if(!strCats){
//		strCats = "all";
//	}
	var strCats = "all";
	fixmystreet.map.layers.forEach(function(element,index,array){
		if(element.options.protocol){
			element.options.protocol.params.categories = strCats;
			element.options.protocol.params.filter_category = "Other category";
			element.options.protocol.params.categories = strCats;
		}
	});
	fixmystreet.markers.refresh({force: true});
}

function toggleCategories(){
	var actualClass = $("#s-categories").attr("class");
	if(actualClass=="s-categories-maximized"){
		$("#s-categories").removeClass().addClass("s-categories-minimized");
		$("#toggle-image").removeClass().addClass("toggle-down");
		$("#categories-filters").css('display','none');
	}else{
		$("#s-categories").removeClass().addClass("s-categories-maximized");
		$("#toggle-image").removeClass().addClass("toggle-up");
		$("#categories-filters").css('display','block');
	}

}
