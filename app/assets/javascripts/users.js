function initForm() {
    $("#old_password").val("");
    $("#new_password").val("");
    $("#confirm_password").val("");
};

//jquery 初始化函数
$(function () {
    initForm();
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
    common_form_ajax_deal();
});

//查询用户搜索
function search() {
    var user_name = $("#user_name").val();
    var user_mobile = $("#user_mobile").val();
    if (user_mobile.length > 11) {
        alert("手机号码不合法!");
        return;
    }
    var prefix_url = "?user_name=" + user_name + "&user_mobile=" + user_mobile;
    window.location.href = get_location_href_no_search() + prefix_url + "&f=" + get_rand_num();
}


//管理员用户>>重置密码
function reset_password(user_id) {
    $.get("/admin/users/" + user_id + "/reset_password", function (data, status) {
            if (data.flag == 1) {
                alert("密码重置成功!")
            } else {
                alert("密码重置失败!")
            }
        }
    );
}

//当前用户修改密码
function checkPwd(){
    var data = {old_password: $("#old_password").val(), new_password: $("#new_password").val()}
    if ($("#old_password").val() == "" || $("#old_password").val().length == 0) {
        alert("旧密码不能为空");
        return false;
    } else if ($("#new_password").val() == "" || $("#new_password").val().length == 0) {
        alert("新密码不能为空")
        return false;
    }else if ($("#confirm_password").val() == "" || $("#confirm_password").val().length == 0){
        alert("确认新密码不能为空")
        return false;
    }else if($("#new_password").val()!=$("#confirm_password").val()){
        alert("新密码和确认新密码,两次输入密码不同")
        return false;
    }else{
        $.post("/admin/users/modify_loginpassword",data,function(data,status){
            if(data.flag==1){
                alert(data.msg)
                window.location.href="/users/sign_in"

            }else{
                alert(data.msg)
                $("#old_password").val("");
                $("#new_password").val("");
                $("#confirm_password").val("");
            }
        });
        return;
    }

}

function initForm() {
    $("#old_password").val("");
    $("#new_password").val("");
    $("#confirm_password").val("");
}

