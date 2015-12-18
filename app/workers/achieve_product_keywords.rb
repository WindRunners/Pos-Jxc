class AchieveProductKeywords
  @queue = :achieves_queue_keywords

  def self.perform(*args)

    userinfo_id, title = args.first, args.last

    url = "http://ltpapi.voicecloud.cn/analysis/?api_key=Q1i484y719X081S7M9V6qCnH8I2RYxFiYGKBVEzZ&text=#{URI.encode(title)}&pattern=ws&format=plain"

    response = HTTParty.get(url)

    response.body.split(' ').each do |word|
      pinyin = Pinyin.t(word)
      py = Pinyin.t(word) { |letters| letters[0] }
      keyword = Keyword.find_or_create_by(word:word,pinyin:pinyin,py:py)
      userinfo = Userinfo.find(userinfo_id)
      userinfo.keywords << keyword
      userinfo.save
    end

  end
end