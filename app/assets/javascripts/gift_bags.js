
//配送员查询
function search(){

    var mobile = $("#search-scope #receiver_mobile").val();
    var sign_status = $("#search-scope #sign_status").val();

    if(mobile.length>11){
        alert("手机号码不合法!");
        return;
    }
    //window.location.href = window.location.pathname+"?mobile="+mobile+"&sign_status="+sign_status;

    var prefix_url = "?mobile="+mobile+"&sign_status="+sign_status+"&f="+get_rand_num();
    window.location.href = get_location_href_no_search()+prefix_url;
    //alert("手机号码为:"+mobile+",状态:"+status+",页面url:"+window.location.pathname);
}


//jquery 初始化函数
$(function(){

    //键盘enter事件
    document.onkeydown=function(event){
        var e = event || window.event || arguments.callee.caller.arguments[0];
        if(e && e.keyCode==27){ // 按 Esc
            //要做的事情
        }
        if(e && e.keyCode==113){ // 按 F2
            //要做的事情
        }
        if(e && e.keyCode==13){ // enter 键
            search();
        }
    };
});
