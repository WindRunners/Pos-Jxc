String.prototype.trim = ->
  this.replace(/(^\s*)|(\s*$)/g,'')
String.prototype.isBlank = ->
  "" == this.trim() || 0 == this.trim().length
Array.prototype.remove = (obj) ->
  for i in [0..this.length - 1]
    temp = this[i]
    if temp == obj
      for k in [i..this.length - 1]
        this[k] = this[k + 1]
        this.length -= 1

Date::format = (fmt) ->
  o =
    "M+": @getMonth() + 1  #月份
    "d+": @getDate()  #天
    "h+": @getHours() #小时
    "m+": @getMinutes() #分钟
    "s+": @getSeconds() #秒
    "q+": Math.floor((@getMonth + 3) / 3) #季度
    S: @getMilliseconds() #毫秒
  fmt = fmt.replace(RegExp.$1, (@getFullYear() + "").substr(4 - RegExp.$1.length))  if /(y+)/.test(fmt)
  for k of o
    fmt = fmt.replace(RegExp.$1, (if (RegExp.$1.length is 1) then (o[k]) else (("00" + o[k]).substr(("" + o[k]).length))))  if new RegExp("(" + k + ")").test(fmt)
  fmt

Highcharts.setOptions
  lang:
     months:["一月","二月","三月","四月","五月","六月","七月","八月","九月","十月","十一月","十二月"]
     shortMonths: [ "01" , "02" , "03" , "04" , "05" , "06" , "07" , "08" , "09" , "10" , "11" , "12"],
     weekdays: ["星期一", "星期二", "星期三", "星期三", "星期四", "星期五", "星期六","星期天"]
#初始化本地语言
moment.locale("zh_cn")

@dataTablesChinese =
  "sProcessing":   "处理中..."
  "sLengthMenu":   "显示 _MENU_ 项结果"
  "sZeroRecords":  "没有匹配结果"
  "sInfo":         "显示第 _START_ 至 _END_ 项结果，共 _TOTAL_ 项"
  "sInfoEmpty":    "显示第 0 至 0 项结果，共 0 项"
  "sInfoFiltered": "(由 _MAX_ 项结果过滤)"
  "sInfoPostFix":  ""
  "sSearch":       "搜索:"
  "sUrl":          ""
  "sEmptyTable":     "表中数据为空"
  "sLoadingRecords": "载入中..."
  "sInfoThousands":  ","
  "oPaginate":
    "sFirst":    "首页"
    "sPrevious": "上页"
    "sNext":     "下页"
    "sLast":     "末页"
  "oAria":
    "sSortAscending":  ": 以升序排列此列"
    "sSortDescending": ": 以降序排列此列"
@dataTableParams =
  "oLanguage": @dataTablesChinese
  "sPaginationType" : "full_numbers"
  "lengthMenu": [2, 5, 10, 15, 20, 25, 50, 100]
  "bDestroy": true
@dataTableAjaxParams =
  "oLanguage": @dataTablesChinese
  "sPaginationType" : "full_numbers"
  "processing": true
  "serverSide": true
  "lengthMenu": [5, 10, 15, 20, 25, 50, 100]
  "bDestroy": true
  "stateSave": true