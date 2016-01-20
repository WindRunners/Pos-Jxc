//jquery 初始化函数
$(function () {

    var customersDataTable =
        $('#customers').DataTable({
            /**
             sScrollY: "200px",//enable vertical scrolling
             sScrollX: "100%",
             sScrollXInner: "120%",//enable horizintal scrolling with its content 120% of its container
             bScrollCollapse: true,
             */
            pageLength: 25,
            bProcessing: true,
            bServerSide: true,
            stateSave: true,
            sAjaxSource: $('#customers').data('source'),
            language: {
                "url": "http://cdn.datatables.net/plug-ins/1.10.10/i18n/Chinese.json"
            }
        });


    //customersDataTable.ajax.url($('#customers').data('source')).load();




});