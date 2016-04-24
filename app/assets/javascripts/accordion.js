$(document).ready(function(){
	$("#accordion h3").click(function(){
		$('#accordion h3').removeClass('on');
		$(this).addClass('on');
		$("#accordion .accordion_content").slideUp();
		if(!$(this).next().is(":visible")) {
			$(this).next().slideDown();
			var h = $( window ).height();
			$("#accordion .accordion_content").css("max-height", h - 203 + 'px');
		}
	});

	$("#filterBar").css("top", "-40px");
	$("#zoom").css("top", "75px");
	$("#filterBar p").html("▼");


	$(".bottomFilter").click(function(){
		if ($("#filterBar").css("top") == "0px" || $("#filterBar").css("top") == "auto"){
			$("#filterBar").animate({
				top: "-40"
			}, 300);
			$("#zoom").animate({
				top: "75"
			}, 300);
			$("#filterBar p").html("▼");
		}
	});

	$(".bottomFilter").click(function(){
		if ($("#filterBar").css("top") == "-40px"){
			$("#filterBar").animate({
				top: "0"
			}, 300);
			$("#zoom").animate({
				top: "120"
			}, 300);
			$("#filterBar p").html("▲");
		}
	});


	$(".close-right").click(function(){
		if ($("#accordion").css("margin-left") == "0px"){
			$("#accordion").animate({
				marginLeft: "-300"
			}, 600);
			$(".close-right p").css("transform", "translateY(-50%) rotateY(180deg)");
		}
		else{
			$("#accordion").animate({
				marginLeft: "0"
			}, 600);
			$(".close-right p").css("transform", "translateY(-50%) rotateY(0deg)");
		}
	});

});

// When a user clicks on a node or edge.
function accordion(item) {
	$(".accordion_content").removeClass('active');
	$(".accordion_content").slideUp();
	$("#accordion h3").removeClass('on');
	$("#" + item + "info").prev().addClass('on');	
	$("#" + item + "info").addClass("active");
	$("#" + item + "info").slideDown();
}