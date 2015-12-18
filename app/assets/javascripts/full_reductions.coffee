# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
@activityProductHash = {}
@giftProductHash = {}
@couponHash = {}
@fullReduction = ->
  @activityProductHash = JSON.parse $("#selectProductHash").val()
  @giftProductHash = JSON.parse $("#giftSelectProductHash").val()
  @couponHash = JSON.parse $("#selectCouponHash").val()
  @originTable = $("#tableProducts").DataTable @dataTableParams
  @giftsOriginTable = $("#giftTableProducts").DataTable @dataTableParams
  @selectedTable = $("#selectedProductsTable").DataTable @dataTableParams
  @giftsSelectedTable = $("#giftSelectedProductsTable").DataTable @dataTableParams
  @couponTable = $("#couponsTable").DataTable @dataTableParams
  @couponSelectedTable = $("#couponSelectedTable").DataTable @dataTableParams
@aasmStateChange = (aasm_state) ->
  aasm_state = aasm_state || ""
  ajaxUrl = $('#full_reductions').data('source')
  @fullReductionsDataTables.ajax.url(ajaxUrl + "&aasm_state=#{aasm_state}").load()
@fullReductionsIndex = ->
  @dataTableAjaxParams["sAjaxSource"] = $('#full_reductions').data('source')
  @fullReductionsDataTables = $("#full_reductions").DataTable @dataTableAjaxParams
@attendActivity = (product_id, isGift, isCoupon) ->
  if isCoupon
    @couponHash[product_id] = if $("#quantity_#{product_id}").val().isBlank() then "1" else $("#quantity_#{product_id}").val()
    $("#selectCouponHash").val JSON.stringify @couponHash
  else
    if !isGift
      @activityProductHash["" + product_id] = ""
      $("#selectProductHash").val JSON.stringify @activityProductHash
    else
      @giftProductHash["" + product_id] = if $("#gifts_quantity_#{product_id}").val().isBlank() then "1" else $("#gifts_quantity_#{product_id}").val()
      $("#giftSelectProductHash").val JSON.stringify @giftProductHash
  buttonObj = $("#" + (if isGift then "gift_" else "") + product_id + "_attend")
  buttonObj.text "已参加"
  buttonObj.prop "class", "btn"
  buttonObj.prop "disabled", true
  trObj = buttonObj.parent().parent().clone()
  buttonCancel = trObj.find("button")
  buttonCancel.prop "disabled", false
  buttonCancel.prop "class", "btn btn-primary"
  buttonCancel.prop "id", (if isGift then "gift_" else "") + product_id + "_cancel"
  buttonCancel.text "取消参加"
  buttonCancel.attr "onclick", "cancelActivity('" + product_id + "', " + isGift + ", " + (if isCoupon then true else false) + ")"
  @selectedTable.row.add(trObj).draw false if !isGift && !isCoupon
  @couponSelectedTable.row.add(trObj).draw false if !isGift && isCoupon
  @giftsSelectedTable.row.add(trObj).draw false if isGift
  # $("#selectedProductsTable > tbody").append trObj

@cancelActivity = (product_id, isGift, isCoupon) ->
  buttonCancel = $("#" + (if isGift then "gift_" else "") + product_id + "_cancel")
  trButtonAttend = buttonCancel.parent().parent().clone()
  trButtonAttendNow = buttonCancel.parent().parent().clone()
  @selectedTable.row(buttonCancel.parent().parent()).remove().draw false if !isGift && !isCoupon
  @couponSelectedTable.row(buttonCancel.parent().parent()).remove().draw false if !isGift && isCoupon
  @giftsSelectedTable.row(buttonCancel.parent().parent()).remove().draw false if isGift
  if isCoupon
    delete @couponHash[product_id]
    $("#selectCouponHash").val JSON.stringify @couponHash
    buttonAttend = $(@couponTable.row(".cls_" + product_id).node()).find("button")
  else
    if !isGift
      delete @activityProductHash["" + product_id]
      $("#selectProductHash").val JSON.stringify @activityProductHash
      buttonAttend = $(@originTable.row(".cls_" + product_id).node()).find("button")
    else
      delete @giftProductHash["" + product_id]
      $("#giftSelectProductHash").val JSON.stringify @giftProductHash
      buttonAttend = $(@giftsOriginTable.row(".cls_" + product_id).node()).find("button")
  buttonAttend.text "参加活动"
  buttonAttend.prop "disabled", false
  buttonAttend.prop "class", "btn btn-primary"