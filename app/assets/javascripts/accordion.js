$(document).ready(function(){
	$("#accordion h3").click(function(){
		$('#accordion h3').removeClass('on');
		$(this).addClass('on');
		$("#accordion div").slideUp();
		if(!$(this).next().is(":visible")) {
			$(this).next().slideDown();
			var h = $( window ).height();
			$("#accordion div").css("max-height", h - 203 + 'px');
		}
	});

	$("#filterBar a").click(function(e) {
	   e.stopPropagation();
	})

	$("#filterBar").click(function(){
		if ($("#filterBar").css("top") == "0px" || $("#filterBar").css("top") == "auto"){
			$("#filterBar").animate({
				top: "-70"
			}, 300);
			$("#zoom").animate({
				top: "50"
			}, 300);
		}
	});

	$("#filterBar").mouseenter(function(){
		if ($("#filterBar").css("top") == "-70px"){
			$("#filterBar").animate({
				top: "0"
			}, 300);
			$("#zoom").animate({
				top: "120"
			}, 300);
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