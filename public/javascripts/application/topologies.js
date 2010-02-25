$(function() {
    $("#topology_root").treeview({
        collapsed: true,
        animated: "medium"
    });
    $(".show_segment_link").click(function() {
        $(".selected-segment").removeClass("selected-segment");
        $(this).parent().addClass("selected-segment");
        $.get($(this).attr("href"), function(data) {
            $("#segment-details").html(data);
            setupSegmentDetails();
        });
        return false;
    });
})

function setupSegmentDetails() {
    var last_tab = $("ul.tab_links li").size() - 1;
    $("#tabs").tabs({selected: last_tab});
    $(".show_installed_asset_link").click(function() {
        var asset_title = $(this).attr("title");
        $.get($(this).attr("href"), function(data) {
            var details = $("#asset-details");
            details.html(data);
            $("#asset-dialog").attr("title", asset_title);
            $("#asset-dialog").dialog({ width: ($(window).width() * .6),
            modal: true });
        });
        return false;
    });
    $(".edit_segment").ajaxForm({
        target: "#segment-details",
        success: setupSegmentDetails
    });
}

