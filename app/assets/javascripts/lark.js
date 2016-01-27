angular.module('lark', [])
    .config(function($httpProvider){
        $httpProvider.defaults.useXDomain = true;
        $httpProvider.defaults.headers.common = 'Content-Type: application/json';
        delete $httpProvider.defaults.headers.common['X-Requested-With'];
    })
    .controller('NoticeController', function ($scope, $http) {
        $scope.notices = [];
        $http({

            url:'/announcements/warehouse_notice_index',

            method:"get",

            headers: {
                'Access-Control-Allow-Origin' : '*',
                'Access-Control-Allow-Methods' : 'POST, GET, OPTIONS, PUT',
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Token token="564ec5f4c3666e5c6b000000"'

            }
        }).success(function(resp){
            $scope.notices = resp;
        });
    });




//获取location的href 包括hash 并且去除?后面的条件
function get_location_href_no_search(){
    var l_hash = location.hash;
    if(l_hash.indexOf("?")!=-1){
        l_hash=l_hash.substring(0,l_hash.indexOf("?"));
    }
    return "http://"+location.host+"/"+l_hash;
}

//获取随机数
function get_rand_num(){
    return Math.floor(Math.random()*1000);
}

//分页添加ajax
function pagination_ajax(){

    $(".pagination a").each(function(){

        var href = $(this).attr('href');
        if(undefined!=href && null!=href){
            $(this).attr('data-href',href);
            $(this).attr('data-url',href);
            $(this).attr('href',"#"+href);
        }
    });
}


//是否存在指定函数
function isExitsFunction(funcName) {
    try {
        if (typeof(eval(funcName)) == "function") {
            return true;
        }
    } catch(e) {}
    return false;
}
//是否存在指定变量
function isExitsVariable(variableName) {
    try {
        if (typeof(variableName) == "undefined") {
            //alert("value is undefined");
            return false;
        } else {
            //alert("value is true");
            return true;
        }
    } catch(e) {}
    return false;
}

//表单ajax提交处理，处理错误信息提示以及成功后页面跳转 适用于（data-remote=true）
function common_form_ajax_deal(){

    $("form[data-remote='true']").on('ajax:success', function(event, xhr, status, error) {

        if(xhr.flag==1){
            $("#error_explanation").hide();
            eval(xhr.path);
        }else{
            $("#error_explanation ul").html("");
            msg_data = xhr.data
            for (msg in msg_data){
                $("#error_explanation ul").append("<li>"+msg_data[msg]+"</li>");
            }
            $("#error_explanation").show();
        }
    });
}