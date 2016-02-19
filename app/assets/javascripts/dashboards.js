/**
 * Created by jyd-pc005 on 16/1/5.
 */
//jquery 初始化函数
$(function(){

    //各门店有效订单量
    $.post("dashboards/store_order_data",function(data){

        $('#store_order_container').highcharts(data);
        //alert(data);
    });


    ////当月商品关注排名
    //$.post("dashboards/exposure_product_data",function(data){
    //
    //    $('#exposure_product_container').highcharts(data);
    //    //alert(data);
    //});


    ////当月商品关注排名
    //$.post("dashboards/sale_product_data",function(data){
    //    alert(JSON.stringify(data));
    //    $('#sale_product_data_container').highcharts(data);
    //    //alert(data);
    //});

});