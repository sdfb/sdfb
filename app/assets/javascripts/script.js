$(document).ready(function() {

    //Tooltips
	$("#onenode").tooltip({placement: 	'right', title: 'Connections of one individual'});
	$("#twonode").tooltip({placement: 	'right', title: 'Mutual connections between two individuals'});
	$("#onegroup").tooltip({placement: 	'right', title: 'Members of one group'});
	$("#twogroup").tooltip({placement: 	'left', title: 'Mutual members of two groups'});

    $("#addnode").tooltip({placement:   'right', title: 'Add a new individual to the database'});
    $("#addgroup").tooltip({placement:  'right', title: 'Add a new group to the database'});
    $("#addedge").tooltip({placement:   'right', title: 'Add and annotate a relationship between two individuals'});

    $("#icon-tag").tooltip({placement:  'right', title: 'Tag group'});
    $("#icon-link").tooltip({placement: 'right', title: 'Add a relationship'});
    $("#icon-annotate").tooltip({placement: 'right', title: 'Annotate relationship'});
    $("#icon-info").tooltip({placement: 'left', title: 'Scroll to zoom, double click on node or edge for more information, single click to reset view'});
    $("#icon-color").tooltip({placement: 'left', title: 'Click to view color legend'});

    $("#node-icon-chain").tooltip({placement: 'right', title: 'Add relationship'});
    $("#node-icon-annotate").tooltip({placement: 'right', title: 'Edit person'});
    $("#edge-icon-annotate").tooltip({placement: 'right', title: 'Edit relationship'});
    $("#group-icon-label").tooltip({placement: 'right', title: 'Add person to group'});
    $("#group-icon-annotate").tooltip({placement: 'right', title: 'Edit group'});

    $(".icon-zoomin").tooltip({placement:  'left', title: 'Zoom In'});
    $(".icon-zoomout").tooltip({placement:  'left', title: 'Zoom Out'});
    $(".icon-color").tooltip({placement:  'left', title: 'Colors'});
    $(".icon-info").tooltip({placement:  'left', title: 'Info'});

    $(".slider").tooltip({placement: 'right', title: 'Choose the certainty of relationship'});
	$('#onenodeform').css('display','block');

    // Color guide
    $("#icon-color").click(function(){
        if( $('#guide').css('display') == 'none' ){
            $("#guide").css('display','block');
        }
        else{
            $("#guide").css('display','none');
        }        
    });
    $("#guide").click(function(){
          $("#guide").css('display','none');
    });

	// Shows search bars when click on side menu
	$('.accordion_content ul li').click(function(e){
		//document.getElementById('googleaddnode').reset();
		//document.getElementById('googleaddedge').reset();
    //    document.getElementById('googleaddgroup').reset();
        $('.accordion_content ul li').removeClass('clicked');
        $(this).addClass('clicked');
		$('section').css('display','none');	
		var id = '#' + e.target.id + 'form';
		$(id).css('display','block');
	});
	$('.toggle').click(function(e){
		$('.toggle').removeClass('active');
		$(this).addClass('active');
	});
	$('#findtwogroup').click(function(e){
		$('#twogroupsmenu').css('display','block');
	});
    $('section button').click(function(e){
        if (this.name == "node") {
            $('#zoom').css('display','block');
        } else if (this.name == "group") {
            $('#zoom').css('display','none');
        }
    });
    $("aside button.icon").click(function(e){
        $('.accordion_content ul li').removeClass('clicked');
        $('section').css('display','none');
        $('#add' + this.name).addClass('clicked');
        $('#add'+ this.name + 'form').css('display','block');
        $('#accordion h3').removeClass('on');
        $('#accordion div').slideUp();
        $('#contribute').prev().addClass('on');
        $('#contribute').slideDown();
    });

 //  Sliding animation
	$("#node-slider").slider({
        animate: true,
        range: "min",
        value: 40,
        min: 0,
        max: 100,
        step: 1,
        // Gets a live reading of the value and prints it on the page
        slide: function( event, ui ) {
        	var result = "Very unlikely";
        	if (ui.value > 19 && ui.value < 40) {
        		result = "Unlikely";
        	} else if (ui.value > 39 && ui.value < 60) {
        		result = "Possible";
        	} else if (ui.value > 59 && ui.value < 80) {
        		result = "Likely";
        	} else if (ui.value > 79){
                result = "Certain"
            }
            $("#slider-result1").html( result + " relationships @ " + ui.value + "%");
            $("#slider-result-hidden1").val(ui.value);
        }
    });

    $("#edge-slider").slider({
        animate: true,
        range: "min",
        value: 40,
        min: 0,
        max: 100,
        step: 1,
        // Gets a live reading of the value and prints it on the page
        slide: function( event, ui ) {
            var result = "Very unlikely";
            if (ui.value > 19 && ui.value < 40) {
                result = "Unlikely";
            } else if (ui.value > 39 && ui.value < 60) {
                result = "Possible";
            } else if (ui.value > 59 && ui.value < 80) {
                result = "Likely";
            } else if (ui.value > 79){
                result = "Certain"
            }
            $("#slideredge-result1").html( result + " relationships @ " + ui.value + "%");
            $("#slideredge-result-hidden1").val(ui.value);
        }
    });

    $("#nav-slider").slider({
        animate: true,
        range: "min",
        value: 40,
        min: 0,
        max: 100,
        step: 1,
        // Gets a live reading of the value and prints it on the page
        slide: function( event, ui ) {
            var result = "Very unlikely";
            if (ui.value > 19 && ui.value < 40) {
                result = "Unlikely";
            } else if (ui.value > 39 && ui.value < 60) {
                result = "Possible";
            } else if (ui.value > 59 && ui.value < 80) {
                result = "Likely";
            } else if (ui.value > 79){
                result = "Certain"
            }
            $("#slidenav-result1").html( result + " relationships @ " + ui.value + "%");
            $("#slidenav-result-hidden1").val(ui.value);
        }
    });

		//  Sliding animation
		$(".slider-date").slider({
					animate: true,
					range: "min",
					value: 3,
					min: 1400,
					max: 1800,
					step: 1,
					values: [ 1400, 1800 ],
					slide: function( event, ui ) {
						$( "#search-date-range1" ).val( ui.values[ 0 ] + " - " + ui.values[ 1 ] );
					}
		});
		$( "#search-date-range1" ).val( $( ".slider-date" ).slider( "values", 0 ) + " - " + $( ".slider-date" ).slider( "values", 1 ) );
		
                //  Sliding animation
        $(".slider-date2").slider({
                    animate: true,
                    range: "min",
                    value: 3,
                    min: 1400,
                    max: 1800,
                    step: 1,
                    values: [ 1400, 1800 ],
                    slide: function( event, ui ) {
                        $( "#searchedge-date-range2" ).val( ui.values[ 0 ] + " - " + ui.values[ 1 ] );
                    }
        });
        $( "#searchedge-date-range2" ).val( $( ".slider-date2" ).slider( "values", 0 ) + " - " + $( ".slider-date2" ).slider( "values", 1 ) );

        //  Sliding animation
        $("#navslider2").slider({
                    animate: true,
                    range: "min",
                    value: 3,
                    min: 1400,
                    max: 1800,
                    step: 1,
                    values: [ 1400, 1800 ],
                    slide: function( event, ui ) {
                        $( "#nav-date-range2" ).val( ui.values[ 0 ] + " - " + ui.values[ 1 ] );
                    }
        });
        $( "#nav-date-range2" ).val( $( "#navslider2" ).slider( "values", 0 ) + " - " + $( "#navslider2" ).slider( "values", 1 ) );
	
        $("#slider1").change(function () {                    
        var newValue = $('#slider1').val();
        var result = "Very unlikely";
            if (newValue > 19 && newValue < 40) {
                result = "Unlikely";
            } else if (newValue > 39 && newValue < 60) {
                result = "Possible";
            } else if (newValue > 59 && newValue < 80) {
                result = "Likely";
            } else if (newValue > 79){
                result = "Certain"
            }
        $("#formConfidence").html(result + " relationships @ " + newValue + "%");
        });

        $("#certainty-anchor").click(function() {
            $("#nav-certainty-slider").toggle( "slow", function() {
            });
        });

        $("#date-anchor").click(function() {
            $("#nav-date").toggle( "slow", function() {
            });
        });
});