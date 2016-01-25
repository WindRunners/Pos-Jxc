class AchieveAnnouncementsBatch
  @queue = :achieves_queue_announcements_batch
  def self.perform(*args)
    announcement_category_id = args[0]
    x = args[1]
    current_user_id = args[2]
      @fwb = ""
      #建立模型
      announcement = Announcement.new
      announcement.announcement_category_id = announcement_category_id
      b = announcement.id.to_s
      FileUtils.makedirs('public/upload/image/announcements/'+ b)
      announcement.title = x[0]
      announcement.source = x[2]
      announcement.release_time = x[3]
      # 正文排版
      line = x[1].split ("\n")
      line.each do |l|
        l = l.strip
        if l.size > 0
          if l.include? "jpg" or l.include? "png" or l.include? "jpeg"
            pic_div = l.gsub(/http.*(jpg|png|jpeg)/) { |c|
              uuid=SecureRandom.uuid
              # 下载
              open('public/upload/image/announcements/'+ b + '/' + uuid + '.jpg', 'wb') do |file|
                begin
                  pic_file =open(c).read
                  file << pic_file
                  # 将图片地址存进数组
                  announcement.pic_path << '/upload/image/announcements/' + b + '/' + uuid + '.jpg'
                  # 压缩图片
                  begin
                  img =  Magick::Image.read('public/upload/image/announcements/'+ b + '/' + uuid + '.jpg').first
                  width = img.columns
                  height = img.rows
                  thumb = img.resize(width * 0.8, height * 0.8)
                  thumb.write('public/upload/image/announcements/'+ b + '/thumb_' + uuid + '.jpg') {self.quality = 50} #compress压缩大小
                  # 将压缩图片地址存进数组
                  announcement.pic_thumb_path << '/upload/image/announcements/' + b + '/thumb_' + uuid + '.jpg'
                  rescue
                    announcement.pic_thumb_path << '/upload/image/announcements/' + b + '/' + uuid + '.jpg'
                  end
                  pic_file.close
                rescue
                end
              end

              # # 替换content原图片链接并转化城IMG标签
              c.replace "<div  class = \"pic_div\"><img style='width:100%;' src='/upload/image/announcements/#{b}/#{uuid}.jpg' /></div>"
            }
            @fwb << pic_div
          else
            l.insert(0, "<p>&nbsp;&nbsp;&nbsp;&nbsp;")
            l.insert(-1, "</p>")
            @fwb << l
          end
        end
      end
      announcement.content = @fwb
      announcement.user_id = current_user_id
      #保存
      announcement.save
  end

end