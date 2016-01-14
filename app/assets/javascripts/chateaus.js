
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
    //TinyMCE
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
    //产区select选择框
    $("#chateau_region").change(function () {
        get_region(0)
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
            //search();
        }
    };

});




var from_submit = function () {
    var chateau_id = $('#btn_chateau_id').val();
    var table = $('#wines_table').DataTable();
    var wine_id = table.row('.selected').data();
    //alert(JSON.stringify(wine_id));
    $.ajax({

        type: "post",
        url: "relate_wine",
        data: {wine_id: wine_id._id},
        dataType: "json",

        success: function (data) {
            $('#exampleModal').modal('hide');
            $('#resultTable').prepend("<tr><td>" + data.name + "</td><td>" + data.category + "</td><td>" + data.price + "</td>" +
                "<td>" + data.hits + "</td><td>" + data.created_at + "</td><td>" + data.status + "</td>" +
                "<td><a  class='btn btn-minier btn-danger' href='/chateaus/" + chateau_id + "/resolve_wine?wine_id=" + wine_id._id + "' data-method='delete' rel='nofollow' data-confirm='Are you sure?'>解除关联</a></td></tr>")
            alert("关联成功！");
        }, error: function (data) {
            $('#exampleModal').modal('hide');
            alert("关联失败！");
        }
    });
}


function save_check() {

    $("#region_select select").removeAttr("name");//移除下拉框name属性
    var val = $("#region_select select:last").val();
    if (val == "0") {
        val = $("#region_select select:last").prev().val();
    }
    $("#chateau_region_hidden").val(val);


    if (val == undefined || val == "" || val == "0") {
        alert("请选择产地！")
        return false;
    }

    return true;
}

function get_region(i) {

    var selectEm = i == 0 ? "#region_select option:selected" : "#region_select" + i + " option:selected";

    var region = jQuery(selectEm).val();

    var p_select = i == 0 ? "#chateau_region" : "#region_select" + i;
    $(p_select).nextAll().remove();//移除后代元素

    if (region == "0") return;

    $.ajax({
        url: "/regions/" + region + "/get_children", type: "post", dataType: "json", success: function (data) {

            if (data.length == 0) return;

            var appendSelectHtml = "<select id='region_select" + (i + 1) + "' onchange='javascript:get_region(" + (i + 1) + ");'>";
            appendSelectHtml += "<option value='0'>--请选择--</option>";
            $(data).each(function () {
                appendSelectHtml += "<option value='" + this.id + "'>" + this.name + "</option>";
            });
            appendSelectHtml += "</select>";
            $("#region_select").append(appendSelectHtml);//追加元素
        }
    });

    //$("#region_select select").removeAttr("name");//移除下拉框name属性
    //$("#region_select select:last").attr("name","");//获取最后一个下拉框设置name属性
}



//查询
function search(){

    var name = $("#search-scope #name").val();
    var status = $("#search-scope #status").val();
    var prefix_url = "?name="+name;
    if(status != null && status!=undefined){
        prefix_url+= "&status="+status
    }

    window.location.href = get_location_href_no_search()+prefix_url+"&f="+get_rand_num();
}