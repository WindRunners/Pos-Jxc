//jquery 初始化函数
$(function () {

    $('#share_log_table').DataTable({
        pageLength: 25,
        bProcessing: true,
        bServerSide: true,
        stateSave: true,
        sAjaxSource: 'product_tickets/share_log/log',
        language: {
            "url": "http://cdn.datatables.net/plug-ins/1.10.10/i18n/Chinese.json"
        }
    });

    var product_ticket_id = $("#product_tickets_id").val();

    var customer_data = $('#customer_data').DataTable({
        pageLength: 25,
        bProcessing: false,
        bServerSide: false,
        stateSave: true,
        sAjaxSource: '/product_tickets/'+product_ticket_id+'/get_customers',
        language: {
            "url": "http://cdn.datatables.net/plug-ins/1.10.10/i18n/Chinese.json"
        }
    });

});

function refresh_datetable(){

    customer_data.url('/product_tickets/'+product_ticket_id+'/get_customers').load();
}
