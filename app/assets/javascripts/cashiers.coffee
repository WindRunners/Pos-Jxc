# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
productsMap = {}

@cashiers = ->
  $("#qrcode").focus()
  $('#authenticity_token').val $('meta[name="csrf-token"]').attr 'content'

#  $('#realMoney').on "mousewheel", -> $('#change').val (Number($('#realMoney').val()) - Number($('#receivablesMoney').val())).toFixed(2)

  $('#realMoney').keyup (event) ->
    #alert event.keyCode
    if 13 == event.keyCode
      clearing false
      return false
    else
      $('#change').val (Number($('#realMoney').val()) - Number($('#receivablesMoney').val())).toFixed(2)

  $("#qrcode").keydown (event) ->
    if 13 == event.keyCode
      $("#qrcode_search").submit()
      return false

  $("#check_customer_search").on "ajax:success", (event, data) ->
    if data.exists
      $("#integral").text data.integral
      $("#customerId").val data.id
    else
      new Pop "温馨提示", "#", "该手机号：#{$("#mobile").val()}还不是会员！"
      $("#mobile").focus()


  $("#qrcode_search").on "ajax:success", (event, data) ->
    #$("#qrcode_search").ajaxSuccess(event, data) ->
    btnAddRow data
    $("#qrcode").val ""

@clearing = (printable) ->
  if Number($('#realMoney').val()) < Number($('#receivablesMoney').val())
    new Pop "温馨提示", "#", "金额不足！"
    $("#realMoney").focus()
    return

  if 0 == Number($('#receivablesMoney').val())
    new Pop "温馨提示", "", "没有购买商品，无法结算！"
    $("#realMoney").val ""
    $('#change').val "0.00"
    $("#qrcode").focus()
    return

  $('#change').val (Number($('#realMoney').val()) - Number($('#receivablesMoney').val())).toFixed(2)
  $('#spanRealMoney').text Number($("#realMoney").val()).toFixed(2)
  $("#spanChange").text $("#change").val()
  ogs = []
  for item, i in $("#cashierTable > tbody tr")
    ogs.push {product_id: {$oid: $(item).attr "product_id" }, quantity: $("#spanQuantity#{$(item).attr "qrcode"}").text()}
  orderPara =
    telephone: $("#mobile").val()
    customer_id: $("#customerId").val()
    useintegral: 10
    ordergoods: ogs
  $.post(
    "/orders/line_order_creat"
    order: JSON.stringify(orderPara)
    (data)->
      if data.success
        do ->
            $("#popMoreLink").prop 'target', '_self'
            new Pop "结算成功！", "/cashiers", "实收：#{$('#realMoney').val()} 找零：#{$('#change').val()}"
            window.location.reload()
      else
        do -> new Pop "结算失败！", "", "有可能是网络问题，请检查一下网络。"
    "json"
  )
  setTimeout "printSmallTicket()", 20 if printable
  undefined

@printSmallTicket = ->
  today = new Date()
  strDateTime = today.getFullYear() + "-"
  strDateTime += (today.getMonth() + 1) + "-"
  strDateTime += today.getDate() + " "
  strDateTime += today.getHours() + ":"
  strDateTime += today.getMinutes() + ":"
  strDateTime += today.getSeconds()
  $("#spanClearing").text strDateTime
  $('#divSmallTicket').jqprint()
  #setTimeout "window.location.reload()", 500
  undefined

@btnAddRow = (data) ->
  rowPrint = ""
  row = ""
  if data and data.qrcode
      objTable = $("#cashierTable > tbody tr")
      data.price = 0.0 if "null" == data.price or !data.price

      if !productsMap["#{data.qrcode}"]
        rowPrint += "<tr id='smallTicketTr#{data.qrcode}'><td class='smallTicketName'>#{data.name}</td>"
        rowPrint += "<td id='tdQuantity#{data.qrcode}'>1</td>"
        rowPrint += "<td>#{data.price}</td></tr>"
        row = "<tr id='cashierTr#{data.qrcode}' product_id='#{data.id}' qrcode='#{data.qrcode}'>"
        productsMap["#{data.qrcode}"] = data.qrcode
        row += "<td>#{data.qrcode}</td>"
        row += "<td>#{data.name}</td>"
        row += "<td class='tdPrice'>#{data.price}</td>"
        row += "<td>0</td>"
        row += "<td class='tdQuantity'>"
        row += "<button onclick='minus($(this).parent())'>-</button>"
        row += "<span id='spanQuantity#{data.qrcode}'>1</span>"
        row += "<button onclick='add($(this).parent())'>+</button>"
        row += "</td>"
        row += "<td class='tdTotalPrice'>#{Number(data.price).toFixed 2}</td>"
        row += "<td><button onclick='btnDeleteRow($(this).parent().parent())'>删除</button></td>"
        row += "</tr>"

        $("#cashierTable > tbody").append row
        $("#tableSmallTicket > tbody").append rowPrint
      else
        $("#spanQuantity#{data.qrcode}").text Number($("#spanQuantity#{data.qrcode}").text()) + 1
        $("#tdQuantity#{data.qrcode}").text $("#spanQuantity#{data.qrcode}").text()
        calculationPrice $("#spanQuantity#{data.qrcode}").parent()

      calculation()
      undefined

@calculation = ->
  quantity = 0
  totalMoney = 0.0
  $("#cashierTable .tdQuantity").each -> quantity += parseInt($(this).find("span:first").text())
  $("#cashierTable .tdTotalPrice").each -> totalMoney += Number($(this).text())
  $("#productQuantity").text quantity
  $("#tdProductQuantity").text quantity
  $("#totalPrice").text totalMoney.toFixed(2)
  $("#receivablesMoney").val totalMoney.toFixed(2)
  $(".spanReceivablesMoney").text totalMoney.toFixed(2)
  undefined

@calculationPrice = (tdObj) ->
  quantity = Number tdObj.find("span:first").text()
  price = Number tdObj.parent().find(".tdPrice:first").text()
  totalPriceObj = tdObj.parent().find ".tdTotalPrice:first"
  totalPriceObj.text (quantity * price).toFixed 2
  undefined

@btnDeleteRow = (trObj) ->
  if trObj
    trObj.remove()
    qrcode = trObj.attr('id').substr 9
    $("#smallTicketTr#{qrcode}").remove()
    productsMap["#{qrcode}"] = undefined
  else
    rownum = $("#cashierTable > tbody tr").length
    if 0 < rownum
      $("#cashierTable tr").last().remove()

  calculation()
  undefined

@clearTable = ->
  $("#cashierTable > tbody").empty()
  calculation()
  productsMap = {}
  undefined

@add = (tdObj) ->
  spanObj = tdObj.find "span:first"
  qrcode = tdObj.parent().attr('id').substr 9
  quantity = Number spanObj.text()
  spanObj.text quantity + 1
  $("#tdQuantity" + qrcode).text quantity + 1
  calculationPrice tdObj
  calculation()
  undefined

@minus = (tdObj) ->
  spanObj = tdObj.find "span:first"
  qrcode = tdObj.parent().attr('id').substr 9
  quantity = Number spanObj.text()
  if 1 < quantity
    spanObj.text quantity - 1
    $("#tdQuantity#{qrcode}").text quantity - 1
    calculationPrice tdObj
    calculation()

  undefined
