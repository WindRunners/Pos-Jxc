# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
@activityProductHash = {}
@activityProductArray = []
@aasmStateChange = (aasm_state) ->
  aasm_state = aasm_state || ""
  ajaxUrl = $('#coupons').data('source')
  @couponsDataTables.ajax.url(ajaxUrl + "?aasm_state=#{aasm_state}").load()
@couponsIndex = ->
  @dataTableAjaxParams["sAjaxSource"] = $('#coupons').data('source')
  @couponsDataTables = $("#coupons").DataTable @dataTableAjaxParams
@coupons = ->
  @originTable = $("#tableProducts").DataTable @dataTableParams
  @selectedTable = $("#selectedProductsTable").DataTable @dataTableParams
  $("#coupon_title").change ->
    couponObj = $("#coupon_title")
    if couponObj.val().isBlank()
      $("#couponId").text "优惠卷标题"
    else
      $("#couponId").text couponObj.val()
  $("#coupon_value").change ->
    couponObj = $("#coupon_value")
    if couponObj.val().isBlank()
      $("#couponAmount").text "0.00"
    else
      $("#couponAmount").text couponObj.val()
  $("#datetimepicker_start_time").on "dp.change", ->
    couponObj = $("#datetimepicker_start_time")
    if couponObj.val().isBlank()
      $("#couponStartTime").text "20xx:00:00"
    else
      $("#couponStartTime").text couponObj.val()
  $("#datetimepicker_end_time").on "dp.change", ->
    couponObj = $("#datetimepicker_end_time")
    if couponObj.val().isBlank()
      $("#couponEndTime").text "20xx:00:00"
    else
      $("#couponEndTime").text couponObj.val()
  $("#coupon_instructions").change ->
    couponObj = $("#coupon_instructions")
    if couponObj.val().isBlank()
      $("#couponInstructions").text "暂无使用说明......"
    else
      $("#couponInstructions").text couponObj.val()
  $("#coupon_order_amount").change ->
    couponObj = $("#coupon_order_amount")
    if couponObj.val().isBlank()
      $("#orderAmount").text "XX"
    else
      $("#orderAmount").text couponObj.val()
  $(".order_amount_select").click ->
    if "0" == $(this).val()
      $("#orderLimit").css "display", "none"
      $("#orderNoLimit").css "display", "block"
    else
      $("#orderLimit").css "display", "block"
      $("#orderNoLimit").css "display", "none"
  $(".cls_use_goods").click ->
    if "0" == $(this).val()
      $("#addProducts").css "display", "none"
    else
      $("#addProducts").css "display", "block"
@toogleActivity = (product_id) ->
  buttonObj = $("#" + product_id + "_attend")
  if "取消" == buttonObj.text()
    @activityProductArray.remove product_id
    delete @activityProductHash["" + product_id]
    buttonObj.text "选取"
  else
    @activityProductHash["" + product_id] = ""
    @activityProductArray.push product_id
    buttonObj.text "取消"
  # $("#sureUse").css "display", if "{}" == JSON.stringify(@activityProductHash) then "none" else "block"
  $("#sureUse").css "display", if 0 == @activityProductArray.length then "none" else "block"
@loadSelectProducts = ->
  $('#selectProducts').load "/coupons/selectProducts.html"
@sureUse = ->
  $("#selectProductHash").val JSON.stringify @activityProductHash
  loadSelectedProducts activityProductArray.join(','), 'a'
@loadSelectedProducts = (product_id, operat) ->
  $('#selectedProducts').load "/coupons/products/#{product_id}/#{operat}.html"
@deleteSelectProduct = (product_id) ->

@cancelActivity = (product_id) ->
  buttonCancel = $("#" + product_id + "_cancel")
  @selectedTable.row(buttonCancel.parent().parent()).remove().draw false
  delete @activityProductHash["" + product_id]
  $("#selectProductHash").val JSON.stringify @activityProductHash
  buttonAttend = $(@originTable.row(".cls_" + product_id).node()).find("button")
  buttonAttend.text "参加活动"
  buttonAttend.prop "disabled", false
  buttonAttend.prop "class", "btn btn-primary"
