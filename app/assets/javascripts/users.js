//jquery 初始化函数
$(function () {

    pagination_ajax();

    $('#user_form').on('ajax:success', function (event, xhr, status, error) {

        if (xhr.flag == 1) {
            $("#error_explanation").hide();
            eval(xhr.path);
        } else {
            $("#error_explanation ul").html("");
            msg_data = xhr.data
            for (msg in msg_data) {
                $("#error_explanation ul").append("<li>" + msg_data[msg] + "</li>");
            }
            $("#error_explanation").show();
        }
    });
});

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
        alert("新密码和确认新密码两次输入密码不一样")
        return false;
    }else{
        $.post("/admin/users/modify_loginpassword",data,function(data,status){
            if(data.flag==1){
                alert("密码修改成功,请确认重新登录!")
                window.location.href="/users/sign_in"

            }else{
                alert("密码修改失败,旧密码错误或服务器异常!")
            }
        });
        return;
    }

}
