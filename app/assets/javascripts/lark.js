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