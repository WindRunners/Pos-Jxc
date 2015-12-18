module ChateauV1APIHelper


  def ChateauV1APIHelper.chateau_list(region_id)
    @chateaus_array = []

    region_id_array = []


    @region = Region.find(region_id)
    region_id_array << @region['_id']
    @region.descendants_and_self.each do |r|
      region_id_array << r['_id']
    end


    @chateaus_array = Chateau.where({:status => 1, 'region_id' => {"$in" => region_id_array}}).limit(10)
  end

end