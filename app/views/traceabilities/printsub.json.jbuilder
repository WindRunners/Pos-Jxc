json.array!(@traceabilities) do |traceability|
  json.extract! traceability,:barcode, :printdate,:seqcode
  json.out_storage traceability.jxc_transfer_bill_detail.transfer_out_stock.storage_name
  json.in_storage traceability.jxc_transfer_bill_detail.transfer_in_stock.storage_name
end