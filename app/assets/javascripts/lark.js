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