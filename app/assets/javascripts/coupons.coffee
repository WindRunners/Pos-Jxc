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
  @initDataTable()
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
    buttonObj.text "选取"
  else
    @activityProductArray.push product_id
    buttonObj.text "取消"
  $("#sureUse").css "display", if 0 == @activityProductArray.length then "none" else "block"

@loadSelectProducts = ->
  $('#selectProducts').load "/coupons/selectProducts.html", ->
    $('#selectProducts').removeAttr "data-ajax-content"

@sureUse = ->
  url = "/coupons/products/#{activityProductArray.join(',')}/a"
  $.getJSON(
    url
    (data)->
      if data.success
        do ->
          @loadDataTable "selected"
      else
        do ->
          alert '添加商品失败！'
  )

@loadDataTable = (type) ->
  $("#sureUse").css "display", "none"
  @activityProductArray = []
  if "selected" == type
    @selectedTable.ajax.url($('#selectedProductsTable').data('source')).load()
  else
    @selectTable.ajax.url($('#selectProductsTable').data('source')).load()

@initDataTable = ->
  @dataTableAjaxParams["sAjaxSource"] = $('#selectProductsTable').data('source')
  @selectTable = $("#selectProductsTable").DataTable @dataTableAjaxParams

  @dataTableAjaxParams["sAjaxSource"] = $('#selectedProductsTable').data('source')
  @selectedTable = $("#selectedProductsTable").DataTable @dataTableAjaxParams

@loadSelectedProducts = (product_id, operat) ->
  $('#selectedProducts').load "/coupons/products/#{product_id}/#{operat}.html", ->
    $('#selectedProducts').removeAttr "data-ajax-content"

@cancelActivity = (product_id) ->
  buttonCancel = $("#" + product_id + "_cancel")

  url = "/coupons/products/#{product_id}/d"
  $.getJSON(
    url
    (data)->
      if data.success
        do ->
          @selectedTable.row(buttonCancel.parent().parent()).remove().draw false
      else
        do ->
          alert '删除商品失败！'
  )
