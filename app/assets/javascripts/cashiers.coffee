# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
productsMap = {}
is_clearing = false
@cashiers = ->
  $("#qrcode").focus()
  $('#authenticity_token').val $('meta[name="csrf-token"]').attr 'content'

  $(document).keyup (event) ->
    if 27 == event.keyCode
      clearTable()
      return false
    if 13 == event.keyCode
      console.log "documen. 11111"
      clearing()
      return false

  $('#realMoney').keyup (event) ->
    if 13 == event.keyCode
      console.log "realMoney. 11111"
      clearing()
      return false
    else
      $('#change').val (Number($('#realMoney').val()) - Number($('#receivablesMoney').val())).toFixed(2)

  $("#qrcode").keyup (event) ->
    if 13 == event.keyCode
      console.log "qrcode. 11111"
      searchQrcode()
      return false

  $("#mobile").keyup (event) ->
    if 13 == event.keyCode
      console.log "mobile. 11111"
      checkMobile()
      return false

  $("#check_customer_search").on "ajax:success", (event, data) ->
    if data.exists
      $("#integral").text data.integral
      $("#customerId").val data.id
      new Pop "", "javascript:void(0)", "该会员：#{$("#mobile").val()} 还有#{data.integral} 积分。"
      $("#qrcode").focus()
    else
      new Pop "", "javascript:void(0)", "该会员：#{$("#mobile").val()} 不存在"
      $("#mobile").focus()

  $("#qrcode_search").on "ajax:success", (event, data) ->
    #$("#qrcode_search").ajaxSuccess(event, data) ->
    btnAddRow data
    $("#qrcode").val ""

@clearing = ->
  if Number($('#realMoney').val()) < Number($('#receivablesMoney').val())
    new Pop "", "javascript:void(0)", "金额不足！"
    $("#realMoney").focus()
    return

  business_user = $('#business_user').val()
  ordertype = $('#ordertype').val()
  if ordertype == "2" && (!business_user? || business_user=="")
    new Pop "", "javascript:void(0)", "挂账单业务人员不能为空！"
    $("#business_user").focus()
    return

  console.log "business_user:#{business_user}"
  console.log "ordertype:#{ordertype}"
#  return
  if 0 == Number($('#receivablesMoney').val())
    new Pop "", "javascript:void(0)", "没有购买商品，无法结算！"
    $("#realMoney").val ""
    $('#change').val "0.00"
    $("#qrcode").focus()
    return

  $('#change').val (Number($('#realMoney').val()) - Number($('#receivablesMoney').val())).toFixed(2)
  $('#spanRealMoney').text Number($("#realMoney").val()).toFixed(2)
  $("#spanChange").text $("#change").val()
  ogs = []
  today = new Date()
  searialNumber = today.format("yyyyMMddhhmmss") + @uuid(6, 16)
  for p of productsMap
    ogs.push {product_id: p, quantity: $("##{p}_product_quantity").text()}
  if 0 < Number($("#integral").val())
    availableTheoryIntegral = Math.floor(Number($("#receivablesMoney").val()) * 0.1)
    useIntegral = if availableTheoryIntegral > Number($("#integral").val()) then Number($("#integral").val()) else availableTheoryIntegral - Number($("#integral").val())
  else
    useIntegral = 0
  orderPara =
    telephone: $("#mobile").val()
    customer_id: $("#customerId").val()
    useintegral: useIntegral
    serial_number: searialNumber
    ordergoods: ogs
    ordertype: ordertype
    business_user: business_user
  $.post(
    "/orders/line_order_creat"
    order: JSON.stringify(orderPara)
    (data)->
      if data.success
        do ->
            $("#popMoreLink").prop 'target', '_self'
            $("#spanClearing").text today.format("yyyy-MM-dd hh:mm:ss")
            $("#member-mobile").text $("#mobile").val()
            $("#serial-number").text searialNumber
            $("#integral").val = Number($("#integral").val()) - useIntegral
            new Pop "结算成功！", "#/cashiers|hash#{Math.random() * 10000}", "实收：#{$('#realMoney').val()} 找零：#{$('#change').val()} 使用了 #{useIntegral} 积分"
            is_clearing = true
      else
        do -> new Pop "结算失败！", "javascript:void(0)", "有可能是网络问题，请检查一下网络。"
    "json"
  )
  undefined

@printSmallTicket = (username) ->
  if !is_clearing
    new Pop "", "javascript:void(0)", "没有结算不能打印小票!"
  else
    $("#small-ticket-cashier").text username
    $('#divSmallTicket').jqprint()
  undefined

@btnAddRow = (data) ->
  rowPrint = ""
  row = ""
  if data and data.qrcode
      data.price = 0.0 if "null" == data.price or !data.price

      if !productsMap["#{data.id}"]
        rowPrint += "<tr id='small_ticket_#{data.id}_product_row'><td class='smallTicketName'>#{data.name}</td>"
        rowPrint += "<td id='small_ticket_#{data.id}_product_quantity'>1</td>"
        rowPrint += "<td>#{data.price}</td></tr>"

        productsMap["#{data.id}"] = data.id
        productInfo = "<div class='product-row' id='#{data.id}_product_row'><div class='col-xs-2 center'>#{data.qrcode}</div>"
        productInfo += "<div class='col-xs-4 center'>#{data.name}</div>"
        productInfo += "<div class='col-xs-1 center' id='#{data.id}_product_price'>#{Number(data.price).toFixed 2}</div>"
        productInfo += "<div class='col-xs-1 center product-quantity' id='#{data.id}_product_quantity'>1</div>"
        productInfo += "<div class='col-xs-1 center product-total-price' id='#{data.id}_product_total_price'>#{Number(data.price).toFixed 2}</div>"
        productInfo += "<div class='col-xs-3 center product-operat'>"
        productInfo += "<span onclick='plus(\"#{data.id}\")'><i class='fa fa-plus-square-o fa-2x'></i></span>"
        productInfo += "<span onclick='minus(\"#{data.id}\")'><i class='fa fa-minus-square-o fa-2x'></i></span>"
        productInfo += "<span onclick='deleteRow(\"#{data.id}\")'><i class='fa fa-trash-o fa-2x'></i></span>"
        productInfo += "</div></div>"

        $("#tableSmallTicket > tbody").append rowPrint
        $("#select-products-body").append productInfo
      else
        $("##{data.id}_product_quantity").text Number($("##{data.id}_product_quantity").text()) + 1
        $("#small_ticket_#{data.id}_product_quantity").text $("##{data.id}_product_quantity").text()
        calculationPrice data.id

      calculation()
      undefined

@calculation = ->
  quantity = 0
  totalMoney = 0.0
  $("#select-products-body .product-quantity").each -> quantity += parseInt($(this).text())
  $("#select-products-body .product-total-price").each -> totalMoney += Number($(this).text())
  $("#productQuantity").text quantity
  $("#tdProductQuantity").text quantity
  $("#totalPrice").text totalMoney.toFixed(2)
  $("#receivablesMoney").val totalMoney.toFixed(2)
  $(".spanReceivablesMoney").text totalMoney.toFixed(2)
  undefined

@calculationPrice = (product_id) ->
  totalPriceObj = $("##{product_id}_product_total_price")
  quantityObj = $("##{product_id}_product_quantity")
  priceObj = $("##{product_id}_product_price")
  totalPriceObj.text (Number(quantityObj.text()) * Number(priceObj.text())).toFixed 2
  undefined

@deleteRow = (product_id) ->
  rowObj = $("##{product_id}_product_row")
  rowObj.remove()
  $("#small_ticket_#{product_id}_product_row").remove()
  delete productsMap["#{product_id}"]
  calculation()
  undefined

@clearTable = ->
  $("#select-products-body").empty()
  $("#tableSmallTicket > tbody").empty()
  $("#realMoney").val ""
  $("#change").val "0.00"
  $("#receivablesMoney").val "0.00"
  $("#customerId").val ""
  $("#integral").text "0"
  $("#mobile").val ""
  $("#qrcode").val ""
  $("#qrcode").focus()
  $(".spanReceivablesMoney").text ""
  $("#spanRealMoney").text ""
  $("#spanChange").text ""
  $("#productQuantity").text "0"
  $("#totalPrice").text "0.00"
  $("#tdProductQuantity").text ""
  productsMap = {}
  is_clearing = false
  undefined

@searchQrcode = ->
  $('#qrcode_search').submit() if !$('#qrcode').val().isBlank()

@checkMobile = ->
  $('#check_customer_search').submit() if !$('#mobile').val().isBlank()

@plus = (product_id) ->
  quantityObj = $("##{product_id}_product_quantity")
  console.log "1111#{quantityObj.text()}"
  quantityObj.text Number(quantityObj.text()) + 1
  console.log "2222#{quantityObj.text()}"
  calculationPrice product_id
  calculation()
  undefined

@minus = (product_id) ->
  quantityObj = $("##{product_id}_product_quantity")
  quantity = Number quantityObj.text()
  if 1 < quantity
    quantityObj.text quantity - 1
    calculationPrice product_id
    calculation()
  undefined
