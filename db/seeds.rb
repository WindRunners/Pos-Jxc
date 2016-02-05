# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


userinfo = Userinfo.create(:name => '管理员',
                           :shopname => '总店',
                           :location => [0,0],
                           :pdistance => 500)

user = User.find_or_create_by( :name => "管理员",
                               :mobile => "12345678900",
                               :email => "admin@aibuluo.com",
                               :password => "123456",
                               :password_confirmation => "123456",
                               :userinfo => userinfo)


State.create(:name => "已上架",
             :value => "online",
             :background => "#00CFFD",
             :color => "white")
State.create(:name => "已下架",
             :value => "offline",
             :background => "#00CFFD",
             :color => "white")


Role.create(:name => "admin",:role_mark => "business")#管理员
Role.create(:name => "staff",:role_mark => "business")#员工
Role.create(:name => "finance",:role_mark => "business")#财务
Role.create(:name => "manager",:role_mark => "business")#经理
Role.create(:name => "store",:role_mark => "business")#门店
Role.create(:name => "business",:role_mark => "business")#运营商


#平台角色
Role.create(:name => "SuperAdmin",:role_mark => "platform")#超级管理员
Role.create(:name => "xiaoda_kuaixun",:role_mark => "platform") #小大快讯
Role.create(:name => "jiu_world",:role_mark => "platform")#酒世界

Region.create(:name => "世界")


## 进销存初始化

#财务账户类型
JxcDictionary.create(:dic => '现金账户',:dic_desc => 'account_type',:pinyin_code => 'xjzh')
JxcDictionary.create(:dic => '银行账户',:dic_desc => 'account_type',:pinyin_code => 'yhzh')
JxcDictionary.create(:dic => '刷卡',:dic_desc => 'account_type',:pinyin_code => 'sk')
JxcDictionary.create(:dic => '线上支付',:dic_desc => 'account_type',:pinyin_code => 'xszf')
JxcDictionary.create(:dic => '虚拟账户(现金等价物)',:dic_desc => 'account_type',:pinyin_code => 'xnzh')

#币种
JxcDictionary.create(:dic => '人民币',:dic_desc => 'currency',:pinyin_code => 'rmb')
JxcDictionary.create(:dic => '美元',:dic_desc => 'currency',:pinyin_code => 'my')
JxcDictionary.create(:dic => '港币',:dic_desc => 'currency',:pinyin_code => 'gb')

#开户银行
JxcDictionary.create(:dic => '中国工商银行',:dic_desc => 'bank_type',:pinyin_code => 'zggsyh')
JxcDictionary.create(:dic => '中国建设银行',:dic_desc => 'bank_type',:pinyin_code => 'zgjsyh')
JxcDictionary.create(:dic => '中国农业银行',:dic_desc => 'bank_type',:pinyin_code => 'zgnyyh')
JxcDictionary.create(:dic => '中国银行',:dic_desc => 'bank_type',:pinyin_code => 'zgyh')
JxcDictionary.create(:dic => '招商银行',:dic_desc => 'bank_type',:pinyin_code => 'zsyh')
JxcDictionary.create(:dic => '交通银行',:dic_desc => 'bank_type',:pinyin_code => 'jtyh')
JxcDictionary.create(:dic => '民生银行',:dic_desc => 'bank_type',:pinyin_code => 'msyh')
JxcDictionary.create(:dic => '上海浦东发展银行',:dic_desc => 'bank_type',:pinyin_code => 'shpdfzyh')
JxcDictionary.create(:dic => '广东发展银行',:dic_desc => 'bank_type',:pinyin_code => 'gdfzyh')
JxcDictionary.create(:dic => '深圳发展银行',:dic_desc => 'bank_type',:pinyin_code => 'szfzyh')

#往来单位类别
JxcDictionary.create(:dic => '酒水供应商',:dic_desc => 'jxc_contacts_unit_category',:pinyin_code => 'jsgys')
JxcDictionary.create(:dic => '团购客户',:dic_desc => 'jxc_contacts_unit_category',:pinyin_code => 'tgkh')
store_retail_consumer = JxcDictionary.create(:dic => '门店零售客户',:dic_desc => 'jxc_contacts_unit_category',:pinyin_code => 'mdlskh')

#仓库类别
central_store_category = JxcDictionary.create(:dic => '总仓库',:dic_desc => 'storage_type',:pinyin_code => 'zck')
sub_store_category = JxcDictionary.create(:dic => '分仓库',:dic_desc => 'storage_type',:pinyin_code => 'fck')
JxcDictionary.create(:dic => '门店仓库',:dic_desc => 'storage_type',:pinyin_code => 'mdck')

#其他入库类型
JxcDictionary.create(:dic => '获赠',:dic_desc => 'stock_in_type',:pinyin_code => 'hz')
JxcDictionary.create(:dic => '代销',:dic_desc => 'stock_in_type',:pinyin_code => 'dx')
JxcDictionary.create(:dic => '借入',:dic_desc => 'stock_in_type',:pinyin_code => 'jr')
JxcDictionary.create(:dic => '代加工',:dic_desc => 'stock_in_type',:pinyin_code => 'djg')

#其他出库类型
JxcDictionary.create(:dic => '赠予',:dic_desc => 'stock_out_type',:pinyin_code => 'zy')
JxcDictionary.create(:dic => '借出',:dic_desc => 'stock_out_type',:pinyin_code => 'jc')
JxcDictionary.create(:dic => '返还',:dic_desc => 'stock_out_type',:pinyin_code => 'fh')

#默认仓库( 总库 )
JxcStorage.create(:storage_name => '总库',
                  :spell_code => 'zk',
                  :storage_type => '总仓库',
                  :admin => user
                  )

JxcStorage.create(:storage_name => '分库',
                  :spell_code => 'fk',
                  :storage_type => '分仓库',
                  :admin => user
                  )

#默认往来单位
JxcContactsUnit.create( :unit_name => '零售客户',
                        :unit_property => '1',
                        :unit_type => '门店零售客户',
                        :spell_code => 'lskh'
                        )
JxcContactsUnit.create( :unit_name => '测试供应商',
                        :unit_property => '0',
                        :unit_type => '酒水供应商',
                        :spell_code => 'csgys'
                      )
