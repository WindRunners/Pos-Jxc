# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
@activityProductHash = {}
@promotionDiscount = ->
  @originTable = $("#tableProducts").DataTable @dataTableParams
  @selectedTable = $("#selectedProductsTable").DataTable @dataTableParams
@attendActivity = (product_id, isPromotion) ->
  @activityProductHash["" + product_id] = "" if !isPromotion
  @activityProductHash["" + product_id] = (if $("#quantity_#{product_id}_").val().isBlank() then "0" else $("#quantity_#{product_id}_").val()) if isPromotion
  $("#selectProductHash").val JSON.stringify @activityProductHash
  buttonObj = $("#" + product_id + "_attend")
  buttonObj.text "已参加"
  buttonObj.prop "class", "btn"
  buttonObj.prop "disabled", true
  trObj = buttonObj.parent().parent().clone()
  buttonCancel = trObj.find("button")
  buttonCancel.prop "disabled", false
  buttonCancel.prop "class", "btn btn-primary"
  buttonCancel.prop "id", product_id + "_cancel"
  buttonCancel.text "取消参加"
  buttonCancel.attr "onclick", "cancelActivity('" + product_id + "', " + isPromotion + ")"
  @selectedTable.row.add(trObj).draw false

@cancelActivity = (product_id, isPromotion) ->
  buttonCancel = $("#" + product_id + "_cancel")
  @selectedTable.row(buttonCancel.parent().parent()).remove().draw false
  delete @activityProductHash["" + product_id]
  $("#selectProductHash").val JSON.stringify @activityProductHash
  @originTable.row(".cls_" + product_id).node()
  buttonAttend = $(@originTable.row(".cls_" + product_id).node()).find("button")
  buttonAttend.text "参加活动"
  buttonAttend.prop "disabled", false
  buttonAttend.prop "class", "btn btn-primary"

@aasmStateChange = (aasm_state) ->
  aasm_state = aasm_state || ""
  ajaxUrl = $('#promotion_discounts').data('source')
  @PromotionDiscountsDataTables.ajax.url(ajaxUrl + "&aasm_state=#{aasm_state}").load()
@PromotionDiscountsIndex = ->
  @dataTableAjaxParams["sAjaxSource"] = $('#promotion_discounts').data('source')
  @PromotionDiscountsDataTables = $("#promotion_discounts").DataTable @dataTableAjaxParams