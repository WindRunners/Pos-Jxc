# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
@img_server = ""
@fullReduction = (img_server)->
  $("#full_reduction_avatar").change ->
    $("#avatar_img").attr "src", img_server + this.value

@aasmStateChange = (aasm_state) ->
  aasm_state = aasm_state || ""
  ajaxUrl = $('#full_reductions').data('source')
  @fullReductionsDataTables.ajax.url(ajaxUrl + "&aasm_state=#{aasm_state}").load()

@fullReductionsIndex = ->
  @dataTableAjaxParams["sAjaxSource"] = $('#full_reductions').data('source')
  @fullReductionsDataTables = $("#full_reductions").DataTable @dataTableAjaxParams
@attendActivity = (product_id, isGift, isCoupon) ->
  buttonObj = $("#" + (if isGift then "gift_" else "") + product_id + "_attend")
  if isGift
    url = "/full_reductions/giftProducts/#{product_id}," + (if $("#quantity_#{product_id}").val().isBlank() then "1" else $("#quantity_#{product_id}").val()) + "/a"
  else if isCoupon
    url = "/full_reductions/coupons/#{product_id}," + (if $("#quantity_#{product_id}").val().isBlank() then "1" else $("#quantity_#{product_id}").val()) + "/a"
  else
    url = "/full_reductions/products/#{product_id}/a"

  $.getJSON(
    url
    (data)->
      if data.success
        do ->
          buttonObj.text "已参加"
          buttonObj.prop "class", "btn"
          buttonObj.prop "disabled", true
      else
        do ->
          alert '选择商品失败！'
  )

@cancelActivity = (product_id, isGift, isCoupon) ->
  buttonCancel = $("#" + (if isGift then "gift_" else "") + product_id + "_cancel")
  if isGift
    url = "/full_reductions/giftProducts/#{product_id}," + $("#quantity_#{product_id}").val() + "/d"
  else if isCoupon
    url = "/full_reductions/coupons/#{product_id}," + $("#quantity_#{product_id}").val() + "/d"
  else
    url = "/full_reductions/products/#{product_id}/d"

  $.getJSON(
    url
    (data)->
      if data.success
        do ->
          if isGift
            @giftsSelectedTable.row(buttonCancel.parent().parent()).remove().draw false
          else if isCoupon
            @couponSelectedTable.row(buttonCancel.parent().parent()).remove().draw false
          else
            @selectedTable.row(buttonCancel.parent().parent()).remove().draw false
      else
        do ->
          alert '选择商品失败！'
  )

@initDataTable = (preferential_way) ->
  if "3" == preferential_way
    @dataTableAjaxParams["sAjaxSource"] = $('#couponsTable').data('source')
    @couponTable = $("#couponsTable").DataTable @dataTableAjaxParams

    @dataTableAjaxParams["sAjaxSource"] = $('#couponSelectedTable').data('source')
    @couponSelectedTable = $("#couponSelectedTable").DataTable @dataTableAjaxParams
  else if "4" == preferential_way || "5" == preferential_way
    @dataTableAjaxParams["sAjaxSource"] = $('#giftTableProducts').data('source')
    @giftsOriginTable = $("#giftTableProducts").DataTable @dataTableAjaxParams

    @dataTableAjaxParams["sAjaxSource"] = $('#giftSelectedProductsTable').data('source')
    @giftsSelectedTable = $("#giftSelectedProductsTable").DataTable @dataTableAjaxParams
  else

  @dataTableAjaxParams["sAjaxSource"] = $('#tableProducts').data('source')
  @originTable = $("#tableProducts").DataTable @dataTableAjaxParams

  @dataTableAjaxParams["sAjaxSource"] = $('#selectedProductsTable').data('source')
  @selectedTable = $("#selectedProductsTable").DataTable @dataTableAjaxParams

@loadSelectCoupon = (objTab, tableId) ->
  @initDataTableAjax(objTab, tableId, @couponTable)

@loadSelectedCoupon = (objTab, tableId) ->
  @initDataTableAjax(objTab, tableId, @couponSelectedTable)

@loadGiftSelectProduct = (objTab, tableId) ->
  @initDataTableAjax(objTab, tableId, @giftsOriginTable)

@loadGiftSelectedProduct = (objTab, tableId) ->
  @initDataTableAjax(objTab, tableId, @giftsSelectedTable)

@loadSelectProduct = (objTab, tableId) ->
  @initDataTableAjax(objTab, tableId, @originTable)

@loadSelectedProduct = (objTab, tableId) ->
  @initDataTableAjax(objTab, tableId, @selectedTable)

@initDataTableAjax = (objTab, tableId, objDataTable) ->
  if !objTab.hasClass('active')
    objDataTable.ajax.url($("##{tableId}").data('source')).load()
