//jquery 初始化函数
$(function () {

    var productsDataTable =
        $('#products').DataTable({
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
                sAjaxSource: $('#products').data('source'),
                language: {
                    "url": "http://cdn.datatables.net/plug-ins/1.10.10/i18n/Chinese.json"
                }
            });

    var mobile_category = $("#mobile_category").select2();

    mobile_category.on("select2:select", function (e) {
        productsDataTable.ajax.url($('#products').data('source') + "&category_id="+mobile_category.val()).load()
    });


    pagination_ajax();

});