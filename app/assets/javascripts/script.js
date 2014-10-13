// $(document).ready(function() {

//  //    Tooltips
// 	// $("#onenode").tooltip({placement: 	'right', title: 'Connections of one individual'});
// 	// $("#twonode").tooltip({placement: 	'right', title: 'Mutual connections between two individuals'});
// 	// $("#onegroup").tooltip({placement: 	'right', title: 'Members of one group'});
// 	// $("#twogroup").tooltip({placement: 	'right', title: 'Mutual members of two groups'});

//  //    $("#addnode").tooltip({placement:   'right', title: 'Add a new individual to the database'});
//  //    $("#addgroup").tooltip({placement:  'right', title: 'Add a member to an existing or new group'});
//  //    $("#addedge").tooltip({placement:   'right', title: 'Add and annotate a relationship between two individuals'});

//  //    $("#icon-tag").tooltip({placement:  'right', title: 'Tag group'});
//  //    $("#icon-link").tooltip({placement: 'right', title: 'Add a relationship'});
//  //    $("#icon-annotate").tooltip({placement: 'right', title: 'Annotate relationship'});
//  //    $("#icon-info").tooltip({placement: 'left', title: 'Scroll to zoom, double click on node or edge for more information, single click to reset view'});
//  //    $("#icon-color").tooltip({placement: 'left', title: 'Click to view color legend'});

//  //    $(".slider").tooltip({placement: 'right', title: 'Choose the certainty of relationship'});
// 	// $('#onenodeform').css('display','block');

//     // Color guide
//     $("#icon-color").click(function(){
//         if( $('#guide').css('display') == 'none' ){
//             $("#guide").css('display','block');
//         }
//         else{
//             $("#guide").css('display','none');
//         }        
//     });
//     $("#guide").click(function(){
//           $("#guide").css('display','none');
//     });

// 	// Shows search bars when click on side menu
// 	$('.accordion_content ul li').click(function(e){
// 		document.getElementById('googleaddnode').reset();
// 		document.getElementById('googleaddedge').reset();
//         document.getElementById('googleaddgroup').reset();
//         $('.accordion_content ul li').removeClass('clicked');
//         $(this).addClass('clicked');
// 		$('section').css('display','none');	
// 		var id = '#' + e.target.id + 'form';
// 		$(id).css('display','block');
// 	});
// 	$('.toggle').click(function(e){
// 		$('.toggle').removeClass('active');
// 		$(this).addClass('active');
// 	});
// 	$('#findtwogroup').click(function(e){
// 		$('#twogroupsmenu').css('display','block');
// 	});
//     $('section button').click(function(e){
//         if (this.name == "node") {
//             $('#zoom').css('display','block');
//         } else if (this.name == "group") {
//             $('#zoom').css('display','none');
//         }
//     });
//     $("aside button.icon").click(function(e){
//         $('.accordion_content ul li').removeClass('clicked');
//         $('section').css('display','none');
//         $('#add' + this.name).addClass('clicked');
//         $('#add'+ this.name + 'form').css('display','block');
//         $('#accordion h3').removeClass('on');
//         $('#accordion div').slideUp();
//         $('#contribute').prev().addClass('on');
//         $('#contribute').slideDown();
//     });

//  //   Sliding animation
// 	$(".slider").slider({
//         animate: true,
//         range: "min",
//         value: 3,
//         min: 0,
//         max: 4,
//         step: 1,
//         // Gets a live reading of the value and prints it on the page
//         slide: function( event, ui ) {
//         	var result = "Very unlikely";
//         	if (ui.value == 1) {
//         		result = "Unlikely";
//         	} else if (ui.value == 2) {
//         		result = "Possible";
//         	} else if (ui.value == 3) {
//         		result = "Likely";
//         	} else if (ui.value == 4){
//                 result = "Certain"
//             }
//             $("#slider-result" + this.attributes.name.nodeValue).html( result + " relationships");
//         },

//         // Updates the hidden form field so we can submit the data using a form
//         // change: function(event, ui) { 
//         //     $("#confidence" + this.attributes.name.nodeValue).attr('value', ui.value);
//         // }
//     });
// });
