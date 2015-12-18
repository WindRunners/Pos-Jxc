
var map = new BMap.Map("container");//初始化地图
map.addControl(new BMap.NavigationControl());  //初始化地图控件
//map.addControl(new BMap.ScaleControl());
//map.addControl(new BMap.OverviewMapControl());
map.enableScrollWheelZoom();    //启用滚轮放大缩小，默认禁用
map.enableContinuousZoom();    //启用地图惯性拖拽，默认禁用
map.addControl(new BMap.NavigationControl());  //添加默认缩放平移控件
map.addControl(new BMap.OverviewMapControl()); //添加默认缩略地图控件
map.addControl(new BMap.OverviewMapControl({ isOpen: true, anchor: BMAP_ANCHOR_BOTTOM_RIGHT }));   //右下角，打开

var point=new BMap.Point(113.663221, 34.7568711);
map.centerAndZoom(point, 15);//初始化地图中心点

var gc = new BMap.Geocoder();//地址解析类
//关键字查询
function serbtn(){
    var addrs = document.getElementById("userinfo_address").value;
    var local = new BMap.LocalSearch(
        map,{renderOptions:{map: map, panel:"txtPanel"},
            pageCapacity:12}
    );
    DomReady.local.search(addrs);
    alert(point);
    //  modify <20151017> <dfj> start
    gc.getPoint(addrs, function(point){
        if (point){
            map.centerAndZoom(point,13);
            map.addOverlay(new BMap.Marler(point));
        }else{
            alert("错误地址")
        }
        //  modify <20151017> <dfj> end
    });

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
    var z = 2
    var addComp = rs.addressComponents;
    var adds =  addComp.province +  addComp.city +  addComp.district +  addComp.street +  addComp.streetNumber ;
    var addr = "当前标记地址：" + addComp.province +  addComp.city +  addComp.district +  addComp.street +  addComp.streetNumber + "<br/>";
    addr += "纬度: " + pt.lat + ", " + "经度：" + pt.lng;
    //alert(addr);
    var infoWindow = new BMap.InfoWindow(addr, opts);  //创建信息窗口对象
    marker.openInfoWindow(infoWindow);
    $("#userinfo_address").val(adds);
    $("#userinfo_lng").val(pt.lng);
    $("#userinfo_lat").val(pt.lat);
}
