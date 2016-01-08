module DashboardsHelper

  #获取门店订单图表数据
  def DashboardsHelper.get_store_order_data(user)

    title = {'text' => '各门店有效订单统计'}
    subtitle = {'text' => '有效订单量'}
    xAxis = {'categories' => []} #x轴
    yAxis = {'title' => {text: '订单量（单）'}, 'plotLines' => [{'value' => 0, 'width' => 1, 'color' => '#808080'}]}
    legend = {'layout' => 'vertical', 'align' => 'right', 'verticalAlign' => 'middle', 'borderWidth' => 0}
    tooltip = {'valueSuffix'=> '单'}
    store_order_data = {}
    Store.where({'userinfo_id'=>user['userinfo_id']}).each_with_index do |store,i|
      store_order_data[store.id] = {'name' => store.name, 'data' => []}
    end

    map = %Q{
        function(){
          emit(this.store_id,1)
        }
      }

    reduce = %Q{

        function(key,values){
          return Array.sum(values);
        }
      }

    group_date_list = DashboardsHelper.get_date_list
    group_date_list.each do |date|
      xAxis['categories'] << date['start'].strftime("%Y-%m-%d")

      #按日期汇总门店有效订单量
      info_list = Ordercompleted.where({'userinfo_id'=>user['userinfo_id'],'workflow_state'=>'completed','created_at'=>{'$gte'=>date['start'],"$lte"=>date['end']}}).map_reduce(map, reduce).out(inline: true)

      order_data = {}
      info_list.each do |v|
        order_data[v['_id']] = v['value']
      end

      store_order_data.each do |store_id,data|
        rows = order_data[store_id].present? ? order_data[store_id] : 0
        data['data'] << rows
      end
    end
    series = store_order_data.values

    json = {}
    json['title'] = title
    json['subtitle'] = subtitle
    json['xAxis'] = xAxis
    json['yAxis'] = yAxis
    json['legend'] = legend
    json['series'] = series
    json['tooltip'] = tooltip
    json['credits'] = {'enabled'=>false}
    json
  end

  #获取受关注商品量
  def DashboardsHelper.get_exposure_product_data(user)

    title = {'text' => '商品曝光量排名统计'}
    subtitle = {'text' => '商品曝光量排名统计'}
    xAxis = {'categories' => ['前十名商品']} #x轴
    yAxis = {'title' => {text: '曝光量（次）'}, 'plotLines' => [{'value' => 0, 'width' => 1, 'color' => '#808080'}]}
    legend = {'layout' => 'vertical', 'align' => 'right', 'verticalAlign' => 'middle', 'borderWidth' => 0}
    tooltip = {'valueSuffix'=> '次'}
    series = []
    Product.shop_id(user['userinfo_id']).order('exposure_num desc').limit(10).each do |product|
      series << {'name'=>product['title'],'data'=>[product['exposure_num']]}
    end

    json = {}
    json['title'] = title
    json['subtitle'] = subtitle
    json['xAxis'] = xAxis
    json['yAxis'] = yAxis
    json['legend'] = legend
    json['series'] = series
    json['tooltip'] = tooltip
    json['chart'] = {'type'=>'column'}
    json['credits'] = {'enabled'=>false}

    json
  end


  #获取受关注商品量未完成
  def DashboardsHelper.get_sale_product_data(user)

    title = {'text' => '商品销量比例统计'}
    subtitle = {'text' => '商品销量比例统计'}

    map = %Q{
        function(){
          emit(this.product_id,this.quantity)
        }
      }

    reduce = %Q{

        function(key,values){
          return Array.sum(values);
        }
      }

    goodsinfo = Ordergoodcompleted.where({'userinfo_id'=>user['userinfo_id']}).map_reduce(map, reduce).out(inline: true)
    series= [{'type'=> 'pie','name'=> '商品销量比例','data'=> []}];

    goodsinfo.each do |product|
      series['data'] << [product['_id'], product['value']]
    end

    json = {}
    json['title'] = title
    json['subtitle'] = subtitle
    json['series'] = series
    json['chart'] = {'type'=>'pie'}
    json['credits'] = {'enabled'=>false}
    json
  end



  private

  def DashboardsHelper.get_date_list

    nowData = Time.now
    b = Time.mktime(nowData.year, nowData.month, nowData.day)
    date_list = []
    sec = 3600*24
    for i in 0..6
      date = {}
      date['start'] = b-(i)*sec
      date['end'] = b-(i-1)*sec
      date_list << date
    end
    # date_list.each do |date|
    #   puts "日期：#{date['start'].strftime("%Y-%m-%d")}，时间段：#{date['start']}~#{date['end']}"
    # end
    date_list.reverse!
    date_list
  end


end
