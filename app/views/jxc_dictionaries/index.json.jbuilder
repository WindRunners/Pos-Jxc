json.array!(@jxc_dictionaries) do |jxc_dictionary|
  json.extract! jxc_dictionary, :id, :dic, :dic_desc, :sort, :pinyin_code
  json.url jxc_dictionary_url(jxc_dictionary, format: :json)
end
