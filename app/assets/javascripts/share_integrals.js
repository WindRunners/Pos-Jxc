function save_check(){

    var share_integral_title = $("#share_integral_title").val();
    var edit_share_integral_id = $("#edit_share_integral_id").val();

    var start_date = $("#start_date").val();
    var end_date = $("#end_date").val();

    if (share_integral_title == undefined || share_integral_title == "") {
        alert("请输入标题！")
        return false;
    };


    if (start_date == undefined || start_date == "" ) {
        alert("请输入开始日期！")
        return false;
    };



    if (end_date == undefined || end_date == "" ) {
        alert("请输入结束日期！")
        return false;
    };


    if (start_date > end_date) {
        alert("开始时间不能大于结束时间！")
        return false;
    };






    $.ajax({
        type: "post",
        url: "share_integrals/share_time_check",
        data: {start_date: start_date,end_date: end_date,edit_share_integral_id: edit_share_integral_id},
        dataType: "json",
        success: function (data) {

            if (data.flag ==0){
                alert(data.message);
                return false;
            };

        },
    });

    return true;


};