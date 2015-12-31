//设置配送员的运营商属性
function set_userinfo(userinfo_id,userinfo_name,userinfo_shopname){

    //alert("设置配送员运营商"+userinfo_id);
    $("#delivery_user_userinfo_id").val(userinfo_id);
    $("#delivery_user_userinfo_name").html(userinfo_name);
    $("#delivery_user_userinfo_shopname").html(userinfo_shopname);
}


//表单验证
function check() {

    var userinfoid = $("#delivery_user_userinfo_id");
    if(userinfoid.length>0 && (userinfoid.val()==undefined || userinfoid.val()=="") ) {
        alert("请选择配送员运营商!");
        return false;
    }
    return true;
}

//配送员查询
function search(){

    if($("#search-scope #mobile").length==0) return ;

    var mobile = $("#search-scope #mobile").val();
    var status = $("#search-scope #status").val();

    if(mobile.length>11){
        alert("手机号码不合法!");
        return;
    }

    window.location.href = get_location_href_no_search()+"?mobile="+mobile+"&status="+status+"&f="+get_rand_num();
    //window.location.href = window.location.pathname+"?mobile="+mobile+"&status="+status;
    //alert("手机号码为:"+mobile+",状态:"+status+",页面url:"+window.location.pathname);
}


//查询运营商
function search_userinfo(){

    if($("#search-scope-userinfo #userinfo_name").length==0) return;
    var userinfo_name = $("#search-scope-userinfo #userinfo_name").val();
    var userinfo_shopname = $("#search-scope-userinfo #userinfo_shopname").val();

    window.location.href = get_location_href_no_search()+"?userinfo_name="+userinfo_name+"&userinfo_shopname="+userinfo_shopname+"&f="+get_rand_num();
    //window.location.href = window.location.pathname+"?mobile="+mobile+"&status="+status;
    //alert("手机号码为:"+mobile+",状态:"+status+",页面url:"+window.location.pathname);
}




//jquery 初始化函数
$(function(){

    //表格选中事件监听
    $('.table tr').click(function(){
        $(this).addClass("info").siblings().removeClass("info");
    });


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

            search(); //查询运营商
            search_userinfo(); //查询运营商
        }
    };

    pagination_ajax();
});





