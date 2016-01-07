# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
@img_server = ""
@promotionDiscount = (img_server)->
  @img_server = img_server
  $("#promotion_discount_avatar").change ->
    $("#avatar_img").attr "src", img_server + this.value
  @selectProducts()
@attendActivity = (product_id, isPromotion) ->
  url = "/promotion_discounts/products/"
  url += "#{product_id}"
  url += "," + (if $("#quantity_#{product_id}").val().isBlank() then "0" else $("#quantity_#{product_id}").val()) if isPromotion
  url += "/a/" + (if isPromotion then "1" else "0")
  $.getJSON(
    url
    (data)->
      if data.success
        do ->
          buttonObj = $("#" + product_id + "_attend")
          buttonObj.text "已参加"
          buttonObj.prop "class", "btn"
          buttonObj.prop "disabled", true
      else
        do ->
          alert '选择商品失败！'
  )

@cancelActivity = (product_id, isPromotion) ->
  buttonCancel = $("#" + product_id + "_cancel")
  url = "/promotion_discounts/products/#{product_id}/d/" + (if isPromotion then "1" else "0")
  $.getJSON(
    url
    (data)->
      if data.success
        do ->
          @selectedTable.row(buttonCancel.parent().parent()).remove().draw false
      else
        do ->
          alert '取消商品失败！'
  )

@aasmStateChange = (aasm_state) ->
  aasm_state = aasm_state || ""
  ajaxUrl = $('#promotion_discounts').data('source')
  @PromotionDiscountsDataTables.ajax.url(ajaxUrl + "&aasm_state=#{aasm_state}").load()
@loadSelectProducts = (objTable)->
  if !objTable.hasClass('active')
    ajaxUrl = $('#tableProducts').data('source')
    @originTable.ajax.url(ajaxUrl).load()
@loadSelectedProducts = (objTable)->
  if !objTable.hasClass('active')
    ajaxUrl = $('#selectedProductsTable').data('source')
    @selectedTable.ajax.url(ajaxUrl).load()
@selectProducts = ->
  @dataTableAjaxParams["sAjaxSource"] = $('#tableProducts').data('source')
  @originTable = $("#tableProducts").DataTable @dataTableAjaxParams
  @dataTableAjaxParams["sAjaxSource"] = $('#selectedProductsTable').data('source')
  @selectedTable = $("#selectedProductsTable").DataTable @dataTableAjaxParams
@PromotionDiscountsIndex = ->
  @dataTableAjaxParams["sAjaxSource"] = $('#promotion_discounts').data('source')
  @PromotionDiscountsDataTables = $("#promotion_discounts").DataTable @dataTableAjaxParams
