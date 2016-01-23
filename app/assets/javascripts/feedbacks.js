//用户建议反馈查询搜索
function search() {
    var real_name = $("#search-scope #real_name").val();
    var mobile = $("#search-scope #mobile").val();
    if (mobile.length > 11) {
        alert("手机号码不合法!");
        return;
    }
    var prefix_url = "?real_name=" + real_name + "&mobile=" + mobile;
    window.location.href = get_location_href_no_search() + prefix_url + "&f=" + get_rand_num();
}


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
    pagination_ajax();
});