$(function() {
    $("#topology_root").treeview({
        collapsed: true,
        animated: "medium"
    });
    $(".show_segment_link").click(function() {
        $.get($(this).attr("href"), function(data) {
            $("#details").html(data);
            registerAjaxForm();
        });
        return false;
    });
})

function registerAjaxForm() {
    $(".edit_segment").ajaxForm({
        target: "#details",
        success: registerAjaxForm
    });
}