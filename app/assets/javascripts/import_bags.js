var table = null;

//jquery 初始化函数
$(function(){

    var img_server = $("#img_server").val();

    //初始化商品选择窗口
    table = $('#products_table').DataTable( {
        "processing": true,
        "serverSide": true,
        "ajax": {
            "url":"/import_bags/products/table/data/",
            "type":"POST"
        },
        "columns" : [
            { "data": "avatar_url" },
            { "data": "title" },
            { "data": "mobile_category_name" },
            { "data": "price" }
        ],
        "createdRow": function ( row, data, index ) {

            //$("tr").attr("_data","test123");
            //alert("row:"+JSON.stringify(row));
            //alert("data:"+JSON.stringify(data));
            //alert("index:"+JSON.stringify(index));
        },
        "columnDefs": [ {
            "targets": 0,
            "data": "avatar_url",
            "render": function ( data, type, full, meta ) {
                return "<img class='product_avatar' src='"+img_server+data+"'/>";
            }
        } ],
        "scrollY": "300px",
        "drawCallback": function( settings ) {

        }
    } );


    $('#products_table tbody').on( 'click', 'tr', function () {
        if ( $(this).hasClass('selected') ) {
            $(this).removeClass('selected');
        }
        else {
            table.$('tr.selected').removeClass('selected');
            $(this).addClass('selected');
        }

        //alert("选中行数:"+table.row('.selected').length);
        //alert(JSON.stringify(table.row('.selected').data()));
    } );


    //初始化商品删除监听
    $("#bag_product_table tbody tr").find("a").click(function(){

        //移除元素
        $(this).parent().parent().remove();
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
            search();
        }
    };

    pagination_ajax();
    common_form_ajax_deal();
});


$('#myModal').on('show.bs.modal', function (event) {

    $(".dataTables_scrollHead").css("width","90%");
    //alert($("#products_table_wrapper .dataTables_scroll .dataTables_scrollHead .dataTables_scrollHeadInner").css("width"));
    //alert($("#products_table_wrapper .dataTables_scroll .dataTables_scrollHead .dataTables_scrollHeadInner table").("width"));
    $("#products_table_wrapper .dataTables_scroll .dataTables_scrollHead .dataTables_scrollHeadInner").css({"width":"100%"});
    $("#products_table_wrapper .dataTables_scroll .dataTables_scrollHead .dataTables_scrollHeadInner table").css({"width":"100%"});
})


function add_select_product(){
    $('#myModal').modal('hide');
    add_tr(table.row('.selected').data());
}

//增加行
function add_tr(data){

    var img_server = $("#img_server").val();

    var trmodel = $("#bag_product_tr").clone();
    trmodel.find(".product_name").html(data.title);
    trmodel.find(".product_avatar_url").html("<img src='"+img_server+data.avatar_url+"'/>");
    trmodel.find("input [name='product_num[]']").val(1);
    trmodel.find("[name='product_id[]']").val(data._id);
    trmodel.find("[name='product_title[]']").val(data.title);
    trmodel.find("[name='product_avatar_url[]']").val(data.avatar_url);
    trmodel.find("a").click(function(){
        //移除元素
        $(this).parent().parent().remove();
    });

    trmodel.removeAttr("id");
    trmodel.show();
    $("#bag_product_table tbody").append(trmodel);
}

//礼包查询
function search(){

    var name = $("#search-scope #name").val();
    var business_user = $("#search-scope #business_user").val();
    var sender_mobile = $("#search-scope #sender_mobile").val();
    var workflow_state = $("#search-scope #workflow_state").val();
    if(sender_mobile.length>11){
        alert("手机号码不合法!");
        return;
    }
    var prefix_url = "?name="+name+"&business_user="+business_user+"&sender_mobile="+sender_mobile;
    if(workflow_state != null && workflow_state!=undefined){
        prefix_url+= "&workflow_state="+workflow_state
    }

    window.location.href = get_location_href_no_search()+prefix_url+"&f="+get_rand_num();
}


//保存修改
function save_check(){

    var length = $("#bag_product_table input[name='product_id[]']").length;
    if (length<2){
        alert("请选择商品!")
        return false;
    }
    return true;
}






//根据不同的节点,弹出不同的审核弹出框
function showWfDealModel(state,id){

    $("#workflowDealModal .modal-footer #close_btn_model").nextAll().remove();//移除按钮
    var commonBtn = $("#workflowDealModal .modal-footer #common_btn_model").clone();
    var closeBtn = $("#workflowDealModal .modal-footer #close_btn_model").clone();
    commonBtn.removeAttr("id").show();
    closeBtn.removeAttr("id").show();

    //设置导入礼包id
    $("#workflowDealModal #workflowDealForm [name='id']").val(id);
    $("#workflowDealModal #workflowDealForm [name='state']").val(state);

    //发起审核
    if(state == "start"){
        $("#workflowDealModal .modal-title").html("礼包审核");
        commonBtn.attr({"onclick":"submitWfDealModel('submit')"}).html("发起审核");
        $("#workflowDealModal .modal-footer").append(commonBtn);
        $("#workflowDealModal #workflowDealForm [name='state']").val('new');
    }else if(state == "new"){//重新审核

        $("#workflowDealModal .modal-title").html("礼包审核");
        commonBtn.attr({"onclick":"submitWfDealModel('cancel')"}).html("作废礼包");

        var commonBtn2 = commonBtn.clone();
        commonBtn2.attr({"onclick":"submitWfDealModel('submit')"}).html("发起重审");
        $("#workflowDealModal .modal-footer").append(commonBtn);
        $("#workflowDealModal .modal-footer").append(commonBtn2);
    }else if(state == "first_check" || state == "second_check"){//一级审核及二级审核

        $("#workflowDealModal .modal-title").html("礼包审核");
        commonBtn.attr({"onclick":"submitWfDealModel('pass')"}).html("通过");

        var commonBtn2 = commonBtn.clone();
        commonBtn2.attr({"onclick":"submitWfDealModel('un_pass')"}).html("不通过");
        $("#workflowDealModal .modal-footer").append(commonBtn);
        $("#workflowDealModal .modal-footer").append(commonBtn2);
    }

    $("#workflowDealModal .modal-footer").append(closeBtn);
    $("#workflowDealModal").modal('show');
}


function submitWfDealModel(event){

    //设置事件
    $("#workflowDealModal #workflowDealForm [name='event']").val(event);
    $("#workflowDealForm").submit();
}