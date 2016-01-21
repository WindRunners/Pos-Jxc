
$ ->
 $('#wines_datatable').DataTable
    processing: true
    serverSide: true
    ajax:
      url: '/wines/datatable'
    "type": "post"
    columns: [
#      { width: "0%", className: "dont_show", searchable: false, orderable: false }
#      { width: "15%" }
#      { width: "35%", className: "row_config" }
#      { width: "null", className: "row_config", searchable: false, orderable: false }
#      { width: "null", className: "row_config", searchable: false, orderable: false }
#      { width: "5%", className: "center", searchable: false, orderable: false }
#      { width: "5%", className: "center", searchable: false, orderable: false }
#      { width: "5%", className: "center", searchable: false, orderable: false }
    ]


#    scope :filter_product_name, -> (product_name) {where("lower(PRODUCTS.NAME) like :search", search: "%#{product_name.downcase}%")}