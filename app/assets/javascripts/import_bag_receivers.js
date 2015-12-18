//配送员查询
function search(){

    var mobile = $("#search-scope #mobile").val();

    if(mobile.length>11){
        alert("手机号码不合法!");
        return;
    }
    window.location.href = window.location.pathname+"?mobile="+mobile;
    //alert("手机号码为:"+mobile+",状态:"+status+",页面url:"+window.location.pathname);
}

//导入表单提交验证
function batch_import_check(){

    var exceldata = $("#excel_data").val();
    if(exceldata==null || exceldata==undefined || exceldata==""){
        alert("请选中导入的excel文件!");
        return false;
    }
    return true;
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