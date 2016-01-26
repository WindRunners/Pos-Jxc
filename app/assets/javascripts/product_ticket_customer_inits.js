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
            //$('#product_ticket_customer_modal').modal('hide')
        }else{
            $("#error_explanation ul").html("");
            msg_data = xhr.data
            for (msg in msg_data){
                $("#error_explanation ul").append("<li>"+msg_data[msg]+"</li>");
            }
            $("#error_explanation").show();
        }
    });
});

