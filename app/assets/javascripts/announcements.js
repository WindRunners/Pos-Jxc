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


    //tinymce初始化
    tinymce.init({
        selector: 'textarea.tinymce',
        height: 500,
        plugins: [
            'advlist autolink lists link image charmap print preview anchor',
            'searchreplace visualblocks code fullscreen',
            'insertdatetime media table contextmenu paste code'
        ],
        toolbar: 'insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image',
    });


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


function submit_form() {
    var excel_file = $('#excel_file_id');
    if (excel_file.val() == "" || excel_file.val() == undefined) {
        alert('请选择文件');
        return false;
    }
};


function batch_delete() {
    var announcement_id_array = [];
    $('input[name="form-field-checkbox"]:checked').each(function () {
        announcement_id_array.push($(this).val());

    });
    if (announcement_id_array.length > 0) {
        $.ajax({
            type: "POST",
            url: "/announcements/batch_delete",
            data: {announcement_id_array: announcement_id_array},
            dataType: "json",
            success: function (data) {
                alert(JSON.stringify(data.message));
                $.each(announcement_id_array, function () {
                    $("#tr_" + this).remove();
                });
            }
        });
    }
    else {
        alert(announcement_id_array.length == 0 ? '你还没有选择任何内容！' : announcement_id_array);
    }
};