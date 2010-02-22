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
    $("#tabs").tabs({selected: 1});
    $(".show_installed_asset_link").click(function() {
        $.get($(this).attr("href"), function(data) {
            var details = $("#asset-details");
            details.html(data);
            $("#asset-dialog").attr("title", asset_title);
            $("#asset-dialog").dialog();
        });
        return false;
    });
    $(".edit_segment").ajaxForm({
        target: "#segment-details",
        success: setupSegmentDetails
    });
}
