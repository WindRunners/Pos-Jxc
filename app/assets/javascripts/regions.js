function from_submit(event){

    //设置事件
    $("#new_region").submit();
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
            //search();
        }
    };




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