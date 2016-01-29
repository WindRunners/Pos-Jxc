json.array!(@traceabilities) do |traceability|
  json.extract! traceability, :id, :barcode, :codetype, :printdate, :jxc_bill_detail_id, :jxc_transfer_bill_detail_id
  json.url traceability_url(traceability, format: :json)
end


