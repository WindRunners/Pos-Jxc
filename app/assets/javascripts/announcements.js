$(function () {
    //分页添加AJAX
    $(".pagination a").each(function () {

        var href = $(this).attr('href');
        if (undefined != href && null != href) {
            $(this).attr('data-href', href);
            $(this).attr('data-url', href);
            $(this).attr('href', "#" + href);
        }
    });
});


//查询
function search() {
    var title = $("#search-scope #title").val();
    var status = $("#search-scope #status").val();
    var announcement_category_id = $("#search-scope #category").val();
    var prefix_url = "?title=" + title;
    if (status != null && status != undefined) {
        prefix_url += "&status=" + status
    }
    ;
    if (announcement_category_id != null && announcement_category_id != undefined && announcement_category_id != 0) {
        prefix_url += "&announcement_category_id=" + announcement_category_id
    }

    window.location.href = get_location_href_no_search() + prefix_url + "&f=" + get_rand_num();
}


//jquery 初始化函数
$(function () {

    //键盘enter事件
    document.onkeydown = function (event) {
        var e = event || window.event || arguments.callee.caller.arguments[0];
        if (e && e.keyCode == 27) { // 按 Esc
            //要做的事情
        }
        if (e && e.keyCode == 113) { // 按 F2
            //要做的事情
        }
        if (e && e.keyCode == 13) { // enter 键
            search();
        }
    };
});


function submit_form() {
    var excel_file = $('#excel_file_id');
    if (excel_file.val() == "" || excel_file.val() == undefined) {
        alert('请选择文件');
        return false;
    }
}