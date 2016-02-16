class Client
  include Mongoid::Document
  belongs_to :userinfo

  belongs_to :creator, :class_name => "User"


  # aasm do
  #   state :waiting, :initial => true #等待
  #   state :starting #启用
  #   state :stoping #停用
  #
  #   event :start do
  #     before do
  #       if waiting?
  #         init_db
  #       end
  #     end
  #     after do
  #       if update_state_all(self.id)
  #         save!
  #       end
  #     end
  #     transitions :from => [:waiting, :stoping], :to => :starting
  #   end
  #
  #   event :stop do
  #     after do
  #       save!
  #     end
  #     transitions :from => :starting, :to => :stoping
  #   end
  #
  # end
  #
  # def update_state_all(id)
  #   # Mongoid::Multitenancy.with_tenant(client_instance) do
  #   #   # Current tenant is set for all code in this block
  #   #   p "client_instance#{client_instance}"
  #   # end
  #   current_user= JxcSetting.current_user
  #   # p "current_user#{current_user}"
  #   if current_user.present? && current_user.jxc_building_user.present?
  #     Client.where(:id => {"$ne" => id}, :jxc_building_user => current_user.jxc_building_user).update_all(:aasm_state => "stoping")
  #     return true
  #   end
  #   return false
  # end
  #
  # def change_state(state)
  #   p state
  #   if state == "on"
  #     start if waiting? || may_start? || stoping?
  #   elsif state == "off"
  #     stop if starting? && may_stop?
  #   end
  # end
  #
  # def init_db
  #   current_user= JxcSetting.current_user
  #   Rails.logger.info "init_db::current_user::#{current_user}"
  #   if current_user.present? && current_user.jxc_building_user.present?
  #     client_instance = Client.where(:jxc_building_user => current_user.jxc_building_user, :aasm_state => "waiting").first
  #     Rails.logger.info "init_db::client_instance::#{client_instance}"
  #   end
  #   if client_instance.present?
  #     Mongoid::Multitenancy.with_tenant (client_instance) do
  #
  #       #凭证摘要
  #       JxcDictionary.create(:dic => "报销费用", :dic_desc => "jxc_voucher_note", :pinyin_code => "bxfy")
  #       JxcDictionary.create(:dic => "支付电话费", :dic_desc => "jxc_voucher_note", :pinyin_code => "zfdhf")
  #       JxcDictionary.create(:dic => "采购原材料", :dic_desc => "jxc_voucher_note", :pinyin_code => "cgycl")
  #       JxcDictionary.create(:dic => "报销差旅费", :dic_desc => "jxc_voucher_note", :pinyin_code => "bxclf")
  #       JxcDictionary.create(:dic => "存入现金", :dic_desc => "jxc_voucher_note", :pinyin_code => "crxj")
  #       JxcDictionary.create(:dic => "销售应收款", :dic_desc => "jxc_voucher_note", :pinyin_code => "xsysk")
  #       JxcDictionary.create(:dic => "提取现金", :dic_desc => "jxc_voucher_note", :pinyin_code => "tqxj")
  #       JxcDictionary.create(:dic => "支付工资", :dic_desc => "jxc_voucher_note", :pinyin_code => "zfgz")
  #       JxcDictionary.create(:dic => "借款", :dic_desc => "jxc_voucher_note", :pinyin_code => "jk")
  #       JxcDictionary.create(:dic => "转银行现金", :dic_desc => "jxc_voucher_note", :pinyin_code => "zyhxj")
  #       JxcDictionary.create(:dic => "支付水电费", :dic_desc => "jxc_voucher_note", :pinyin_code => "zfsdf")
  #       JxcDictionary.create(:dic => "支付车贷", :dic_desc => "jxc_voucher_note", :pinyin_code => "zfcd")
  #       JxcDictionary.create(:dic => "支付房租", :dic_desc => "jxc_voucher_note", :pinyin_code => "zffz")
  #       #凭证字
  #       JxcDictionary.create(:dic => "记", :dic_desc => "jxc_credentials", :pinyin_code => "j")
  #       JxcDictionary.create(:dic => "收", :dic_desc => "jxc_credentials", :pinyin_code => "s")
  #       JxcDictionary.create(:dic => "付", :dic_desc => "jxc_credentials", :pinyin_code => "f")
  #       JxcDictionary.create(:dic => "转", :dic_desc => "jxc_credentials", :pinyin_code => "z")
  #       JxcDictionary.create(:dic => "现收", :dic_desc => "jxc_credentials", :pinyin_code => "xs")
  #       JxcDictionary.create(:dic => "银收", :dic_desc => "jxc_credentials", :pinyin_code => "ys")
  #       JxcDictionary.create(:dic => "现付", :dic_desc => "jxc_credentials", :pinyin_code => "xf")
  #       JxcDictionary.create(:dic => "银付", :dic_desc => "jxc_credentials", :pinyin_code => "yf")
  #
  #       ## 进销存初始化
  #
  #       #财务账户类型
  #       JxcDictionary.create(:dic => '现金账户', :dic_desc => 'account_type', :pinyin_code => 'xjzh')
  #       JxcDictionary.create(:dic => '银行账户', :dic_desc => 'account_type', :pinyin_code => 'yhzh')
  #       JxcDictionary.create(:dic => '刷卡', :dic_desc => 'account_type', :pinyin_code => 'sk')
  #       JxcDictionary.create(:dic => '线上支付', :dic_desc => 'account_type', :pinyin_code => 'xszf')
  #       JxcDictionary.create(:dic => '虚拟账户(现金等价物)', :dic_desc => 'account_type', :pinyin_code => 'xnzh')
  #
  #       #币种
  #       JxcDictionary.create(:dic => '人民币', :dic_desc => 'currency', :pinyin_code => 'rmb')
  #       JxcDictionary.create(:dic => '美元', :dic_desc => 'currency', :pinyin_code => 'my')
  #       JxcDictionary.create(:dic => '港币', :dic_desc => 'currency', :pinyin_code => 'gb')
  #
  #       #开户银行
  #       JxcDictionary.create(:dic => '中国工商银行', :dic_desc => 'bank_type', :pinyin_code => 'zggsyh')
  #       JxcDictionary.create(:dic => '中国建设银行', :dic_desc => 'bank_type', :pinyin_code => 'zgjsyh')
  #       JxcDictionary.create(:dic => '中国农业银行', :dic_desc => 'bank_type', :pinyin_code => 'zgnyyh')
  #       JxcDictionary.create(:dic => '中国银行', :dic_desc => 'bank_type', :pinyin_code => 'zgyh')
  #       JxcDictionary.create(:dic => '招商银行', :dic_desc => 'bank_type', :pinyin_code => 'zsyh')
  #       JxcDictionary.create(:dic => '交通银行', :dic_desc => 'bank_type', :pinyin_code => 'jtyh')
  #       JxcDictionary.create(:dic => '民生银行', :dic_desc => 'bank_type', :pinyin_code => 'msyh')
  #       JxcDictionary.create(:dic => '上海浦东发展银行', :dic_desc => 'bank_type', :pinyin_code => 'shpdfzyh')
  #       JxcDictionary.create(:dic => '广东发展银行', :dic_desc => 'bank_type', :pinyin_code => 'gdfzyh')
  #       JxcDictionary.create(:dic => '深圳发展银行', :dic_desc => 'bank_type', :pinyin_code => 'szfzyh')
  #
  #       #往来单位类别
  #       JxcDictionary.create(:dic => '酒水供应商', :dic_desc => 'jxc_contacts_unit_category', :pinyin_code => 'jsgys')
  #       JxcDictionary.create(:dic => '团购客户', :dic_desc => 'jxc_contacts_unit_category', :pinyin_code => 'tgkh')
  #       JxcDictionary.create(:dic => '门店零售客户', :dic_desc => 'jxc_contacts_unit_category', :pinyin_code => 'mdlskh')
  #
  #       #仓库类别
  #       JxcDictionary.create(:dic => '总仓库', :dic_desc => 'storage_type', :pinyin_code => 'zck')
  #       JxcDictionary.create(:dic => '分仓库', :dic_desc => 'storage_type', :pinyin_code => 'fck')
  #       JxcDictionary.create(:dic => '门店仓库', :dic_desc => 'storage_type', :pinyin_code => 'mdck')
  #
  #       #其他入库类型
  #       JxcDictionary.create(:dic => '获赠', :dic_desc => 'stock_in_type', :pinyin_code => 'hz')
  #       JxcDictionary.create(:dic => '代销', :dic_desc => 'stock_in_type', :pinyin_code => 'dx')
  #       JxcDictionary.create(:dic => '借入', :dic_desc => 'stock_in_type', :pinyin_code => 'jr')
  #       JxcDictionary.create(:dic => '代加工', :dic_desc => 'stock_in_type', :pinyin_code => 'djg')
  #
  #       #其他出库类型
  #       JxcDictionary.create(:dic => '赠予', :dic_desc => 'stock_out_type', :pinyin_code => 'zy')
  #       JxcDictionary.create(:dic => '借出', :dic_desc => 'stock_out_type', :pinyin_code => 'jc')
  #       JxcDictionary.create(:dic => '返还', :dic_desc => 'stock_out_type', :pinyin_code => 'fh')
  #
  #
  #     end
  #   end
  #
  # end

end
