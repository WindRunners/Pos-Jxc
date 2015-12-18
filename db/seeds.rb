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
                       :mobile => "admin",
                       :email => "admin@aibuluo.com",
                       :password => "123456",
                       :password_confirmation => "123456",
                       :userinfo => userinfo)


State.create(:name => "已入库",
             :value => "stocking",
             :background => "#85FF00",
             :color => "white")
State.create(:name => "补货中",
             :value => "restocking",
             :background => "#00CFFD",
             :color => "white")
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


Region.create(:name => "世界")