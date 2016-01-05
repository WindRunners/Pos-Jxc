# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
@cashesStateChange = (aasm_state) ->
  aasm_state = aasm_state || ""
  ajaxUrl = $('#integrals').data('source')
  @cashDataTables.ajax.url(ajaxUrl + "?state=#{aasm_state}").load()
@cashIndex = ->
  $('#cashes').DataTable
    sPaginationType: "full_numbers"
    sAjaxSource: $('#cashes').data('source')
    language: {"url": "http://cdn.datatables.net/plug-ins/1.10.10/i18n/Chinese.json"}