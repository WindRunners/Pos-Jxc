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

function reset_password(user_id) {
    $.get("/admin/users/"+user_id+"/reset_password", function (data, status) {
            if (data.flag == 1) {
                alert("密码重置成功!")
            }else {
                alert("密码重置失败!")
            }
        }
    );
}


