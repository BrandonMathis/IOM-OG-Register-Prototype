$(function() {
    $("#topology_root").treeview({
        collapsed: true,
        animated: "medium"
    });
    $(".show_segment_link").click(function() {
        $.get($(this).attr("href"), function(data) {
            $("#segment-details").html(data);
            registerAjaxForm();
        });
        return false;
    });
})

function registerAjaxForm() {
    $("#tabs").tabs({selected: 1});
    $(".edit_segment").ajaxForm({
        target: "#segment-details",
        success: registerAjaxForm
    });
}
