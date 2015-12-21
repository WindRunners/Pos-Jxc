$(function () {
    //分页添加AJAX
    $(".pagination a").each(function(){

        var href = $(this).attr('href');
        if(undefined!=href && null!=href){
            $(this).attr('data-href',href);
            $(this).attr('data-url',href);
            $(this).attr('href',"#"+href);
        }
    });
});


//表单验证
function check() {

    var userinfoid = $("#delivery_user_userinfo_id");
    if (userinfoid.length > 0 && (userinfoid.val() == undefined || userinfoid.val() == "")) {
        alert("请选择配送员运营商!");
        return false;
    }
    return true;
}

//查询
function search(){

    var title = $("#search-scope #title").val();
    var status = $("#search-scope #status").val();
    var prefix_url = "?title="+title;
    if(status != null && status!=undefined){
        prefix_url+= "&status="+status
    }

    window.location.href = get_location_href_no_search()+prefix_url+"&f="+get_rand_num();
}


//jquery 初始化函数
$(function () {

    //表格选中事件监听
    $('.table tr').click(function () {
        $(this).addClass("info").siblings().removeClass("info");
    });


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
    var excel_file = $('#excel_file');
    if (excel_file.val() == "" || excel_file.val() == undefined) {
        alert('请选择文件');
        return false;
    }
}

