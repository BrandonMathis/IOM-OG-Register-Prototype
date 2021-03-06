$(function() {
    $("#topology_root").treeview({
        collapsed: true,
        animated: "medium"
    });
    $(".show_segment_link").click(function() {
        $(".selected-segment").removeClass("selected-segment");
        $(this).addClass("selected-segment");
        $.get($(this).attr("href"), function(data) {
            $("#segment-details").html(data);
            setupSegmentDetails();
        });
        return false;
    });
    setupAssetDetails();
    setupSegmentDetails();
})

function setupSegmentDetails() {
    $("#segment_tabs").tabs({selected: 0});
    $(".show_installed_asset_link").click(function() {
        var asset_title = $(this).attr("title");
        $.get($(this).attr("href"), function(data) {
            var details = $("#asset-details");
            details.html(data);
            setupAssetDetails();
            $("#asset_dialog").attr("title", asset_title);
            $("#asset_dialog").dialog({ width: ($(window).width() * .6),
            modal: true });
        });
        return false;
    });
    $(".edit_segment").ajaxForm({
        target: "#segment-details",
        success: postEditSegment
    });
}

function getLastSegmentTab() { return $("div#segment_tabs > ul.tab_links li").size() - 1; }

function postEditSegment() {
  setupSegmentDetails();
  $("#segment_tabs").tabs('select', getLastSegmentTab());
}

function setupAssetDetails() {
    var last_tab = $("div#asset_tabs > ul.tab_links li").size() - 1;
    $("#asset_tabs").tabs({selected: 0});
}
