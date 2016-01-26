class JxcBaseModel
  include Mongoid::Document

  #单据类型
  BillType_PurchaseStockIn = 'purchase_stock_in'  #采购入库
  BillType_PurchaseReturns = 'purchase_returns'   #采购退货
  BillType_SellStockOut = 'sell_stock_out'        #销售出库
  BillType_SellReturns = 'sell_returns'           #销售退货
  BillType_StockReduce = 'stock_reduce'           #盘亏
  BillType_StockOverflow = 'stock_overflow'       #盘盈
  BillType_StockTransfer = 'stock_transfer'       #调拨
  BillType_StockAssign = 'stock_assign'           #要货
  BillType_OtherStockIn = 'other_stock_in'        #其他入库
  BillType_OtherStockOut = 'other_stock_out'      #其他出库
  BillType_CostAdjust = 'cost_adjust'             #成本调整
  BillType_EnteringStock = 'entering_stock'       #期初库存录入


  #单据操作类型
  OperationType_StockIn = '0'       #入库
  OperationType_StockOut = '1'      #出库
  OperationType_Reduce = '2'        #报损
  OperationType_Overflow = '3'      #报溢
  OperationType_StrikeBalance = '4' #红冲
  OperationType_CostAdjust = '5'    #成本调整


  #单据状态类型
  BillStatus_Create = '0'        #创建
  BillStatus_Audit = '1'        #审核
  BillStatus_StrikeBalance = '2'  #红冲
  BillStatus_Invalid = '-1'       #作废



  #进销存  记录库存变更日志
  def inventoryChangeLog(bill_info,bill_detail_info,previous_count,after_count,price,operation_type,bill_type,bill_status)

    changeLog = JxcStorageJournal.new

    changeLog.resource_product_id = bill_detail_info.resource_product_id  #库粗变更商品ID (商品为 ActiveResource Object)
    changeLog.jxc_storage = bill_info.jxc_storage
    changeLog.user = bill_info.handler[0]

    changeLog.previous_count = previous_count
    changeLog.after_count = after_count
    changeLog.count = after_count.to_d - previous_count.to_d
    changeLog.price = price
    changeLog.amount = bill_detail_info.amount
    changeLog.op_type = operation_type

    changeLog.bill_no = bill_info.bill_no  #单据编号
    changeLog.bill_type = bill_type
    changeLog.bill_status = bill_status
    changeLog.bill_create_date = bill_info.created_at.strftime('%Y/%m/%d')

    #设置库存变更日志的关联单据
    case bill_type
      when BillType_PurchaseStockIn
        changeLog.jxc_purchase_stock_in_bill = bill_info
      when BillType_PurchaseReturns
        changeLog.jxc_purchase_returns_bill = bill_info
      when BillType_SellStockOut
        changeLog.jxc_sell_stock_out_bill = bill_info
      when BillType_SellReturns
        changeLog.jxc_sell_returns_bill = bill_info
      when BillType_StockReduce
        changeLog.jxc_stock_reduce_bill = bill_info
      when BillType_StockOverflow
        changeLog.jxc_stock_overflow_bill = bill_info
      when BillType_StockTransfer
        changeLog.jxc_stock_transfer_bill = bill_info
      when BillType_StockAssign
        changeLog.jxc_stock_assign_bill = bill_info
      when BillType_OtherStockIn
        changeLog.jxc_other_stock_in_bill = bill_info
      when BillType_OtherStockOut
        changeLog.jxc_other_stock_out_bill = bill_info
      else
        puts '未知单据类型'
    end

    changeLog.save
  end

end
