# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#@orderStateChange = (aasm_state) ->
#  aasm_state = aasm_state || ""
#  ajaxUrl = $('#userIntegrals').data('source')
#  @couponsDataTables.ajax.url(ajaxUrl + "?aasm_state=#{aasm_state}").load()
#@userIntegralsIndex = ->
#  @dataTableAjaxParams["sAjaxSource"]=$('#userIntegrals').data('source')
#  @couponsDataTables=$("#userIntegral").DataTable @dataTableAjaxParams
@intagralStateChange = (aasm_state) ->
  aasm_state = aasm_state || ""
  ajaxUrl = $('#integrals').data('source')
  @userIntegralsDataTables.ajax.url(ajaxUrl + "?state=#{aasm_state}").load()
@userIntegralsIndex = ->
  $('#integrals').DataTable
    sPaginationType: "full_numbers"
#    bProcessing:true
#    bServerSide: true
    sAjaxSource: $('#integrals').data('source')
    language: {"url": "http://cdn.datatables.net/plug-ins/1.10.10/i18n/Chinese.json"}





