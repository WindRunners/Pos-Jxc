//jquery 初始化函数
$(function () {
    //键盘enter事件
    document.onkeydown = function (event) {
        var e = event || window.event || arguments.callee.caller.arguments[0];
        if (e && e.keyCode == 27) { // 按 Esc
            //要做的事情
        }
        if (e && e.keyCode == 113) { // 按 F2
            //要做的事情
        }
        if (e && e.keyCode == 13) { // enter 键
            search();
        }
    };
    pagination_ajax();



});


var scripts = [null, null]
$('.page-content-area').ace_ajax('loadScripts', scripts, function () {
    //inline scripts related to this page
});


var map = new BMap.Map("store-map");//初始化地图
map.addControl(new BMap.NavigationControl());  //初始化地图控件
map.enableScrollWheelZoom();    //启用滚轮放大缩小，默认禁用
map.enableContinuousZoom();    //启用地图惯性拖拽，默认禁用
map.addControl(new BMap.NavigationControl());  //添加默认缩放平移控件


var point=new BMap.Point(113.663221, 34.7568711);
map.centerAndZoom(point, 15);//初始化地图中心点

var gc = new BMap.Geocoder();//地址解析类
//关键字查询
function serbtn(){
    var addrs = document.getElementById("position").value;
    var local = new BMap.LocalSearch(
        map,{renderOptions:{map: map, panel:"txtPanel"},
            pageCapacity:12}
    );
    DomReady.local.search(addrs);
    alert(point);
}
//关键字查询
function map_search(){
    var myKeys = document.getElementById("userinfo_address").value;
    var index = 0;
    var myGeo = new BMap.Geocoder();
    myGeo.getPoint(add, function(point){
        if (point) {
            document.getElementById("result").innerHTML +=  index + "、" + add + ":" + point.lng + "," + point.lat + "</br>";
            var address = new BMap.Point(point.lng, point.lat);
            addMarker(address,new BMap.Label(index+":"+add,{offset:new BMap.Size(20,-10)}));
        }
    }, "合肥市");
}

//添加标记点击监听
map.addEventListener("click", function(e){

    var circle = new BMap.Circle(e.point,100,
        {fillColor:"blue", strokeWeight: 1 ,fillOpacity: 0.3, strokeOpacity: 0.3});
    map.addOverlay(circle);
    gc.getLocation(e.point, function(rs){
        showLocationInfo(e.point, rs);
    });

});

//ip定位城市
function myFun(result){
    var cityName = result.name;
    map.setCenter(cityName);

}
var myCity = new BMap.LocalCity();
myCity.get(myFun);

//显示地址信息窗口
function showLocationInfo(pt, rs){
    var marker = new BMap.Marker(pt); //初始化地图标记
    map.centerAndZoom(pt, 18); //设置中心点坐标和地图级别
    map.addOverlay(marker); //将标记添加到地图中

    var opts = {
        width : 250,     //信息窗口宽度
        height: 100,     //信息窗口高度
        title : ""  //信息窗口标题
    }
    var addComp = rs.addressComponents;
    var adds =  addComp.province +  addComp.city +  addComp.district +  addComp.street +  addComp.streetNumber ;
    var addr = "当前标记地址：" + addComp.province +  addComp.city +  addComp.district +  addComp.street +  addComp.streetNumber + "<br/>";
    addr += "纬度: " + pt.lat + ", " + "经度：" + pt.lng;
    //alert(addr);
    var infoWindow = new BMap.InfoWindow(addr, opts);  //创建信息窗口对象
    marker.openInfoWindow(infoWindow);
    $("#position").val(adds);
    $("#longitude").val(pt.lng);
    $("#latitude").val(pt.lat);
}



//查询
function search(){
    var name = $("#search-scope #name").val();
    var prefix_url = "?name="+name;
    window.location.href = get_location_href_no_search()+prefix_url+"&f="+get_rand_num();
}