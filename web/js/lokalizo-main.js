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

});