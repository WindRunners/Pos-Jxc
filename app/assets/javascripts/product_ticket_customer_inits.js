//jquery 初始化函数

var datatable = null;
$(function () {

    datatable = $('#product_ticket_customer').DataTable({
        pageLength: 25,
        bProcessing: true,
        bServerSide: true,
        stateSave: true,
        sAjaxSource: $('#product_ticket_customer').data('source')
    });

    $('#new_product_ticket_customer').on('ajax:success', function(event, xhr, status, error) {

        if(xhr.flag==1){
            $("#error_explanation").hide();
            datatable.ajax.url($('#product_ticket_customer').data('source')).load();//刷新主页
            $('#product_ticket_customer_modal').modal('hide')
        }else{
            $("#error_explanation ul").html("");
            msg_data = xhr.data
            for (msg in msg_data){
                $("#error_explanation ul").append("<li>"+msg_data[msg]+"</li>");
            }
            $("#error_explanation").show();
        }
    });


    $("#start_date").datepicker({
        format: 'YYYY-MM-DD',
        startDate: '-3d'
    });

    $("#end_date").datepicker({
        format: 'YYYY-MM-DD',
        startDate: '-3d'
    });



    //初始化商品删除监听
    $("#import_customer").click(function(){

        var start_date = $("#import_form #start_date").val();
        var end_date = $("#import_form #end_date").val();
        var min_records = $("#import_form #min_records").val();

        if(start_date==""){
            alert("开始时间不能为空");
            return;
        }

        if(end_date==""){
            alert("截止时间不能为空");
            return;
        }

        if(min_records==""){
            alert("订单量最少不能低于1");
            return;
        }

        var startDate = new Date(start_date.replace(/-/g,"/"));
        var endDate = new Date(end_date.replace(/-/g,"/"));

        if(startDate > endDate){
            alert("开始时间不能大于截止时间！");
            return;
        }


        if(min_records<1){
            alert("订单量最少不能低于1");
            return;
        }

        $("#import_customer").attr('disabled',true);

        var url = $("#import_customer_url").val()+"?start_date="+startDate.format("yyyy-MM-dd")+"&end_date="+endDate.format("yyyy-MM-dd")+"&min_records="+min_records;
        $.get(url,function(result,status){

            $("#import_customer").attr('disabled',false);
            if(result.flag ==1){
                datatable.ajax.url($('#product_ticket_customer').data('source')).load();//刷新主页
            }else{
            }
            alert(result.data);
            //alert("Data: " + JSON.stringify(data) + "nStatus: " + status);
        });


        //var startDate = new Date(Date.parse("2016/01/01"));
        //alert(startDate);
        //var days = 4;
        //var userinfo_id = "userinfo_id";
        //
        //alert(1);
        //
        //for (var i=0; i<days; i++){
        //
        //    startDate.setDate(startDate.getDate()+i);
        //    var y = startDate.getFullYear()+'';
        //    var m = startDate.getMonth()+1+'';
        //    var d = startDate.getDate()+'';
        //    alert(y+":"+m+":"+d);
        //}
    });

    //$("#import_form .input-daterange").datepicker({autoclose:true});

});


function remove(id){

    //alert(id);
    //return;

    $.get("/product_ticket_customer_inits/"+id+"/remove",function(result,status){
        if(result.flag ==1){
            datatable.ajax.url($('#product_ticket_customer').data('source')).load();//刷新主页
        }else{
        }
        alert(result.msg);
    });
}

