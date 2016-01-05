# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@intagralStateChange = (aasm_state) ->
  aasm_state = aasm_state || ""
  ajaxUrl = $('#integrals').data('source')
  @userIntegralsDataTables.ajax.url(ajaxUrl + "?state=#{aasm_state}").load()


@userIntegralsIndex = ->
  @dataTableAjaxParams["sAjaxSource"] = $('#integrals').data('source')
  @userIntegralsDataTables = $("#integrals").DataTable @dataTableAjaxParams





