var francisID = 10000473;
var default_sconfidence = 60;
var default_econfidence = 100;
var default_sdate = 1400;
var default_edate = 1800;
  
/*
Num_rels Cluster    Color
 0-1		0        orange
 2-3		1        yellow
 4-5		2        aqua blue
 6-7		3        marine blue
 8-9		4        light blue
 10-11	5        hot pink
 12+		6        purple

*/

// //returns cluster number based on number of relationships the cluster has
<<<<<<< HEAD
function getClusterRels(node){
	try{
		var size = Object.keys(node).length;
	}
	catch(err) {
		var size = 0;
	}

   if (size >= 50){
     return 6;
   } else if (size >= 30){
     return 5;
   } else if (size >= 20) {
     return 4;
   } else if (size >=10) {
     return 3;
   } else if (size >=5) {
     return 2;
   } else if (size >=1) {
     return 1;
   } else {
     return 0;
   }
}
//returns colors based on cluster group number
function getColorsRels(){
   return { 0: "#bdbdbd", 1: "#d73027", 2: "#fc8d59", 3: "#fee090", 4: "#abd9e9", 5: "#74add1", 6: "#4575b4"}
}

//returns cluster number based on number of relationships the cluster has
=======
>>>>>>> cde2e2de3e2dc774376914be4552579b80a0506f
// function getClusterRels(node){
// 	try{
// 		var size = Object.keys(node).length;
// 	}
// 	catch(err) {
// 		var size = 0;
// 	}

<<<<<<< HEAD
//   if (size >= 50){
//     return 6;
//   } else if (size >= 30){
//     return 5;
//   } else if (size >= 20) {
//     return 4;
//   } else if (size >=10) {
//     return 3;
//   } else if (size >=5) {
//     return 2;
//   } else if (size >=1) {
//     return 1;
//   } else {
//     return 0;
//   }
=======
// 	if (size > 100){
// 		return 10;
// 	}else{
// 		return (Math.floor(size / 2)) / 10;
// 	}
>>>>>>> cde2e2de3e2dc774376914be4552579b80a0506f
// }
// //returns colors based on cluster group number
// function getColorsRels(){
//    return { 0: "#bf5b17", 1: "#d73027", 2: "#fc8d59", 3: "#fee090", 4: "#e0f3f8", 5: "#91bfdb", 6: "#4575b4"}
// }

//returns cluster number based on number of relationships the cluster has
function getClusterRels(node){
  try{
    var size = Object.keys(node).length;
  }
  catch(err) {
    var size = 0;
  }

  if (size >= 50){
    return 6;
  } else if (size >= 30){
    return 5;
  } else if (size >= 20) {
    return 4;
  } else if (size >=10) {
    return 3;
  } else if (size >=5) {
    return 2;
  } else if (size >1) {
    return 1;
  } else {
    return 0;
  }
}

//returns colors based on cluster group number
function getColorsRels(){
   return { 0: "#bdbdbd", 1: "#d73027", 2: "#fc8d59", 3: "#fee090", 4: "#abd9e9", 5: "#74add1", 6: "#4575b4"}
}

// Checks if a value is in an array
function notInArray(arr, val) {
  var i = arr.length;
  while (i--) {
    if (arr[i][0] == val[0] && arr[i][1] == val[1]) {
      return false;
    }
    if (arr[i][1] == val[0] && arr[i][0] == val[1]) {
      return false;
    }
  }
  return true;
}

//creates a nodekey associative array with node info
function createNodeKey(node, id) {
  return {"text": node["display_name"].replace(" ", "_"), "size": 10, "id": id,  "cluster": getClusterRels(node["rel_sum"])};

}

function twoDegs(id, id2, people) {
	var keys = {};
	var edges = [];
  var nodes = [];
	function createGraph(id, people) {
  	var p = people[id];
  	$.each(p.rel_sum, function(index, value) { 
  	  var q = value[0];
  		keys[q] = createNodeKey(people[q],q);
      console.log(keys[q]);
  		if (notInArray(edges, [id, value[0]])) {
  		 edges.push([id, value[0]]);
      }
      $.each(people[q].rel_sum, function(index, value1) { 
        var r = value1[0];
        if (r in people){
          keys[r] = createNodeKey(people[r],r);
          if (notInArray(edges, [value[0], value1[0]])) {
           edges.push([value[0], value1[0]]);
          }
        }
      });
    });
    //adds main person's id referenced to keys associative array. Keys represent all data in graph
    keys[id] = {"text": p["display_name"].replace(" ", "_"), "size": 30, "id": id,  "cluster": getClusterRels(p["rel_sum"])}; 
  }
  createGraph(id, people);
  if (id2 != 0 && id2 != ""){
      createGraph(id2, people);
      keys[id2] = {"text": people[id2]["display_name"], "size": 30, "id": id2,  "cluster": getClusterRels(people[id2]["rel_sum"])}; 
      keys[id] = {"text": people[id]["display_name"], "size": 30, "id": id,  "cluster": getClusterRels(people[id]["rel_sum"])}; 
  }
  $.each(keys, function(index, value) {
    nodes.push(value); //adds each key to nodes array
  });

    edges.reverse();
    var w = window.innerWidth;
    var h = window.innerHeight;
    var options = { width: w, height: h, collisionAlpha: 25, colors: getColorsRels() };
    var graph = new Insights($("#graph")[0], nodes, edges, options).render();

    graph.on("node:click", function(d) {
      var clicked = people[d.id];
      $.ajax({
            type: "GET",
            url:    "/node_info", // should be mapped in routes.rb
            data: {node_id:d.id},
            datatype:"html", // check more option
            success: function(data) {
                     // handle response data
                     },
            async:   true
          });  
      accordion("node");
    });
	
    graph.on("edge:click", function(d) {
        var id1 = parseInt(d.source.id);
        var id2 = parseInt(d.target.id);
        $.ajax({
            type: "GET",
            url:    "/network_info", // should be mapped in routes.rb
            data: {source_id:d.source.id, target_id:d.target.id},
            datatype:"html", // check more option
            success: function(data) {
                     // handle response data
                     },
            async:   true
          });  
        accordion("edge");
    });
    graph.tooltip("<div class='btn' >"+"{{text}}".replace("_", " ") + "</div>");
    $('#zoom button.icon').click(function(e){
        if (this.name == 'in') {
            graph.zoomIn();
            graph.center();
        } else if (this.name == 'out') {
            graph.zoomOut();
            graph.center();
        }
    });
}

$('#zoom button.icon').click(function(e){
    if (this.name == 'in') {
      graph.zoomIn();
    } else {
      graph.zoomOut();
    }
  });

// Returns string stating confidence based on input decimal (0<n1.00)
function getConfidence(n) {
    if (0 <= n &&  n<= 19) {
        return "Very Unlikely";}
    else if (20 <= n &&  n<= 39) {
        return "Unlikely";}
    else if (40 <= n &&  n<= 59) {
        return "Possible";}
    else if (60 <= n && n<= 79) {
        return "Likely";}
    else {
        return "Certain";}
}

function getParam ( sname ){
    var params = location.search.substr(location.search.indexOf("?")+1);
    var sval = "";
    params = params.split("&");
    // split param and value into individual pieces
    //$("#Sir-Mix-a-Lot").html(row.contributor); 
    for (var i=0; i<params.length; i++){
        temp = params[i].split("=");
        if ( [temp[0]] == sname ) { 
            sval = temp[1]; 
        }
    }
    return sval;
}

function filterGraph(people){
    var ID = getParam("id");
    var ID2 = getParam("id2");
    if(ID2 == "" || ID2 == "0"){
        ID2 = 0;
    } 
    if(ID == ""){
        ID = francisID;
    }
    twoDegs(ID, ID2, people);
}

function initGraph(people){
  var confidence = default_sconfidence + " to " + default_econfidence
  var date = default_sdate + " - " + default_edate
  if (getParam('id') > 0){
    var name = people[parseInt(getParam('id'))].display_name
  }else{
    var name = people[francisID].display_name
  }
  if (getParam('id2') > 0){
    var name2 = " and " + people[parseInt(getParam('id2'))].display_name
  }else{
    var name2 = ""
  }
  if (getParam('confidence').length > 0){
      confidence = getParam('confidence').replace(',', '% to ')
  }
  if (getParam('date').length > 0){
      date = getParam('date').replace(',', ' to ')
  }
  $("#results").html("Two degrees of " + name + name2 + " at " + confidence + "% from " + date);
  //click methods for all the 'find' buttons in the search bar
  //this should not use the entire peopletoarray instead it should use whatever value is passed through by the #one
  $("#search-network-submit").click(function () {
  	var table = 'no';
    Pace.restart();
    // make the index equal autocomplete
    var id = $("#search-network-name-id").val();
    if ($("#show-table").val() == 1) {
    	table = 'yes'
    }
    var confidence = $("#search-network-slider-confidence-result-hidden").val().split(" - ");
    var date = $("#search-network-slider-date-result-hidden").val().split(" - ");
    window.location.href = '/?id=' + id + '&confidence=' + confidence + '&date=' + date + '&table=' + table;
  });

   $("#search-shared-network-submit").click(function () {
      var table = 'no';
      Pace.restart();
      if ($("#search-shared-network-name1-id").val()) {
        var id1 = $("#search-shared-network-name1-id").val();
      }
      if ($("#search-shared-network-name2-id").val()) {
        var id2 = $("#search-shared-network-name2-id").val();
      }
      if ($("#show-table").val() == 1) {
        table = 'yes'
      }
      var confidence = $("#search-shared-network-slider-confidence-result-hidden").val().split(" - ");
      var date = $("#search-shared-network-slider-date-result-hidden").val().split(" - ");
      window.location.href = '/?id=' + id1 + '&id2=' + id2 + '&confidence=' + confidence + '&date=' + date + '&table=' + table;
    });

  $("#search-group-submit").click(function () {
    Pace.restart();
    // make the index equal autocomplete
    var id = $("#search-group-name-id").val();
    window.location.href = '/?group=' + id;
  });

  $("#search-shared-group-submit").click(function () {
    Pace.restart();
    // make the index equal autocomplete
    var id1 = $("#search-shared-group-name1-id").val();
    var id2 = $("#search-shared-group-name2-id").val();
    window.location.href = '/?group=' + id1 + '&group2=' + id2;
  });

  $("#nav-filter-submit").click(function (){
    var ID = getParam("id");
    var ID2 = getParam("id2")
    if (ID2 != ""){
      ID2Str = "&id2=" + ID2
    }
    else{
      ID2Str = ""
    }
    var confidence = $("#nav-slider-confidence-result-hidden").val().split(" - ");
    var date = $("#nav-slider-date-result").val().split(" - ");
    if ( ID != ""){
      window.location.href = '/?id=' + ID + ID2Str + '&confidence=' + confidence + '&date=' + date;
    }
    if (ID == ""){
      window.location.href = '/?id=' + francisID + ID2Str + '&confidence=' + confidence + '&date=' + date;  
    }

  });

  $("aside button.icon").click(function(){
    addNodes = [];
    addEdges = [];
    var name = $('#node-name').html() + " (" + $('#node-bdate').html() + ")";
    if (this.id == "icon-tag") {
      $("#entry_1177061505").val(name);
    } else if (this.id == "icon-link") {
      $("#entry_768090773").val(name);
    }
  });
}

function init() {
	var people = window.gon.people;
	var group_data = window.gon.group_data;
  var group = window.gon.group;
  var group2 = window.gon.group2;
  var group_members = window.gon.group_members;
  if (getParam("group").length == 0){
  	filterGraph(people);
  	initGraph(people);
  	$('#group-table').hide();
  }else{
     accordion("group"); 	
  	$("#filterBar").hide();
  	$("#group-name").text(group["name"]);
  	$("#group-description").text(group["description"]);
  	if (typeof group2 != 'undefined'){
	  	$("#group-name2").text(group2["name"]);
	  	$("#group-description2").text(group2["description"]);
	  	$(".group2").show();
	  }
    $.each(group_members, function(index, value) { 
      $( "#group-table" ).append( "<div class='group-row'><div class='col-md'>" + group_members[index]["display_name"] + "</div><div class='col-md'>" + group_members[index]["ext_birth_year"] + "</div><div class='col-md'>" + group_members[index]["ext_death_year"] + "</div><div class='col-md'><a href='/people/" + group_members[index]["id"] + "'>" + + group_members[index]["id"] + "</a></div></div>");
    });
  }
}

$(document).ready(function() {
  init();  

});      