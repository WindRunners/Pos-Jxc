json.array!(@traceabilities) do |traceability|
  json.extract! traceability,:barcode, :printdate,:seqcode
  json.storage traceability.jxc_bill_detail.jxc_storage.storage_name
end
