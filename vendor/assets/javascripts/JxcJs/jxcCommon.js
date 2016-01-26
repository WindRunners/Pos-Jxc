//由于 js 浮点数 普通运算 bug，所以 自定义 普通运算方法

//加法调用：accAdd(arg1,arg2)
//返回值：arg1加上arg2的精确结果
function accAdd(arg1,arg2){
    var r1,r2,m;
    try{ r1=String(arg1).split('.')[1].length; }catch(e){ r1=0; }
    try{ r2=String(arg2).split('.')[1].length; }catch(e){ r2=0; }
    m=Math.pow(10,Math.max(r1,r2));
    return ((arg1*m+arg2*m)/m).toFixed(2);
}

//乘法调用：accMul(arg1,arg2)
//返回值：arg1乘以arg2的精确结果
function accMul(arg1,arg2){
    var m=0,s1=String(arg1),s2=String(arg2);
    try{m+=s1.split(".")[1].length;}catch(e){}
    try{m+=s2.split(".")[1].length;}catch(e){}
    return (Number(s1.replace(".",""))*Number(s2.replace(".",""))/Math.pow(10,m)).toFixed(2);
}

//除法调用：accDiv(arg1,arg2)
//返回值：arg1除以arg2的精确结果
function accDiv(arg1,arg2){
    var t1=0,t2=0,r1,r2;
    try{t1=String(arg1).split(".")[1].length;}catch(e){}
    try{t2=String(arg2).split(".")[1].length;}catch(e){}

    with(Math){
        r1=Number(String(arg1).replace(".",""));
        r2=Number(String(arg2).replace(".",""));
        return ((r1/r2)*pow(10,t2-t1)).toFixed(2);
    }
}

//  单据数值结算  //

//计算单据详情金额
function calcBillDetailAmount(detailID){
    var price = $('#'+detailID+' #billDetail_price').val();
    var count = $('#'+detailID+' #billDetail_count').val();

    $('#'+detailID+' #billDetail_amount').val(accMul(price,count));
}

//计算 未到货/未发货 数量
function calcOtherCount(detailID){
    var count = $('#'+detailID+' #billDetail_count').val();
    var haveDoneCount = $('#'+detailID+' #billDetail_have_done_count').val();

    $('#'+detailID+' #billDetail_other_count').val(accAdd(count,-haveDoneCount))
}

//计算 盈亏数量
function calcPLCount(detailID,obj){
    var inventoryCount = $('#'+detailID+' #billDetail_inventory_count').val();
    //var checkCount = $('#'+detailID+' #billDetail_check_count').val();
    var checkCount = $(obj).val();

    $('#'+detailID+' #billDetail_count').val(accAdd(checkCount,-inventoryCount));

    calcBillDetailAmount(detailID);
}

//计算 调拨差额
function calcTransferAmount(detailID){
    var costPrice = $('#'+detailID+' #billDetail_cost_price').val();
    var transferPrice = $('#'+detailID+' #billDetail_price').val();
    var count = $('#'+detailID+' #billDetail_count').val();

    $('#'+detailID+' #billDetail_transfer_amount').val(accMul(accAdd(transferPrice,-costPrice),count));

    calcBillDetailAmount(detailID);
}

//计算 成本调整金额
function calcCostAdjustAmount(detailID){
    var adjustedPrice = $('#'+detailID+' #billDetail_adjusted_price').val();
    var originPrice = $('#'+detailID+' #billDetail_origin_price').val();
    var count = $('#'+detailID+' #billDetail_inventory_count').val();
    var costAdjustAmount = accMul(accAdd(adjustedPrice,-originPrice),count);

    $('#'+detailID+' #billDetail_amount').val(costAdjustAmount);
}

// 根据 装箱规格 及 箱数 计算基本数量
function calcPrimaryCount(detailID){
    var pack_spec = $('#'+detailID+' #billDetail_pack_spec').val();
    var package_count = $('#'+detailID+' #billDetail_package_count').val();
    var primary_count = accMul(pack_spec,package_count);

    $('#'+detailID+' #billDetail_count').val(primary_count);

    calcBillDetailAmount(detailID);
}