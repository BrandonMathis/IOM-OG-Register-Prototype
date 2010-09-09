// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function() {
	$(".asset-name").toggle(
		function() {
			$(this).siblings("img").attr("src", "images/asset_expanded.png")
		},
		function(){
			$(this).siblings("img").attr("src", "images/asset_collapsed.png")
	});
	$(".icon").toggle(
		function() {
			$(this).attr("src", "images/asset_expanded.png")
		},
		function(){
			$(this).attr("src", "images/asset_collapsed.png")
	});
});