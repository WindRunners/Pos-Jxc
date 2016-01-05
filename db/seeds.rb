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

User.find_or_create_by(:name => "管理员",
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


Role.create(:name => "admin")

Role.create(:name => "staff")

#财务
Role.create(:name       => "finance")
#经理
Role.create(:name       => "manager")
#超级管理员
Role.create(:name       => "SuperAdmin")

#门店
Role.create(:name       => "store")
#运营商
Role.create(:name       => "business")


#门店
Role.create(:name       => "store")
#运营商
Role.create(:name       => "business")
Role.create(:name => "xiaoda_kuaixun") #小大快讯
Role.create(:name => "jiu_world")#酒世界


Region.create(:name => "世界")





