class AnnouncementsController < ApplicationController
  before_action :set_announcement, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:app_show]

  # GET /announcements
  # GET /announcements.json
  def index
    status_condition=params[:status] || ''
    title_condition=params[:title] || ''
    category_condition =params[:announcement_category_id] || ''
    conditionParams = {}
    conditionParams['announcement_category_id'] = category_condition if category_condition.present?
    conditionParams['status'] = status_condition if status_condition.present?
    conditionParams['title'] = /#{title_condition}/ if title_condition.present?
    @announcements = Announcement.where(conditionParams).page(params[:page]).order('created_at DESC')
  end

  # GET /announcements/1
  # GET /announcements/1.json
  def show
  end

  # GET /announcements/new
  def new
    @announcement = Announcement.new
  end

  # GET /announcements/1/edit
  def edit
  end


  # POST /announcements
  # POST /announcements.json
  def create
    @announcement = Announcement.new(announcement_params)
    @announcement.user = current_user
    @announcement.read_num = 0
    @announcement.status = 0
    b = @announcement.id.to_s
    FileUtils.makedirs('public/upload/image/announcements/'+ b)
    i =params[:announcement]['content']
    @announcement.content = i.gsub(/src.*(jpg|png|jpeg)/) { |a|
      c = a[5, a.length]
      uuid=SecureRandom.uuid
      # 下载
      open('public/upload/image/announcements/'+ b + '/' + uuid + '.jpg', 'wb') do |file|
        begin
          pic_file =open(c).read
          file << pic_file
          # 将图片地址存进数组
          @announcement.pic_path << '/upload/image/announcements/' + b + '/' + uuid + '.jpg'
          # 压缩图片
          begin
          img = Magick::Image.read('public/upload/image/announcements/'+ b + '/' + uuid + '.jpg').first
          width = img.columns
          height = img.rows
          thumb = img.resize(width * 0.5, height * 0.5)
          thumb.write('public/upload/image/announcements/'+ b + '/thumb_' + uuid + '.jpg') { self.quality = 50 } #compress压缩大小
          # 将压缩图片地址存进数组
          @announcement.pic_thumb_path << '/upload/image/announcements/' + b + '/thumb_' + uuid + '.jpg'
          rescue
            @announcement.pic_thumb_path << '/upload/image/announcements/' + b + '/' + uuid + '.jpg'
          end
          pic_file.close
        rescue
        end
      end
      # 替换content原图片链接并转化城IMG标签
      a.replace 'src="/upload/image/announcements/' + @announcement.id + '/' + uuid + '.jpg'
    }
    respond_to do |format|
      if @announcement.save
        format.js { render_js announcements_path }
        format.json { render :show, status: :created, location: @announcement }
      else
        format.html { render :new }
        format.json { render json: @announcement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /announcements/1
  # PATCH/PUT /announcements/1.json
  def update
    i =params[:announcement]['content']
    @announcement.title = params[:announcement]['title']
    @announcement.announcement_category_id = params[:announcement]['announcement_category_id']
    @announcement.description = params[:announcement]['description']
    @announcement.is_top = params[:announcement]['is_top']
    b = @announcement.id.to_s
    @announcement.content = i.gsub(/src.*(jpg|png|jpeg)/) { |a|
      if !a.include? 'upload/image/announcements'
        c = a[5, a.length]
        uuid=SecureRandom.uuid
        # 下载
        open('public/upload/image/announcements/'+ b + '/' + uuid + '.jpg', 'wb') do |file|
          begin
            pic_file =open(c).read
            file << pic_file
            # 将图片地址存进数组
            @announcement.pic_path << '/upload/image/announcements/' + b + '/' + uuid + '.jpg'
            # 压缩图片
            begin
              img = Magick::Image.read('public/upload/image/announcements/'+ b + '/' + uuid + '.jpg').first
              width = img.columns
              height = img.rows
              thumb = img.resize(width * 0.5, height * 0.5)
              thumb.write('public/upload/image/announcements/'+ b + '/thumb_' + uuid + '.jpg') { self.quality = 50 } #compress压缩大小
              # 将压缩图片地址存进数组
              @announcement.pic_thumb_path << '/upload/image/announcements/' + b + '/thumb_' + uuid + '.jpg'
            rescue
              @announcement.pic_thumb_path << '/upload/image/announcements/' + b + '/' + uuid + '.jpg'
            end
            pic_file.close
          rescue
          end
        end
        a.replace 'src="/upload/image/announcements/' + @announcement.id + '/' + uuid + '.jpg'
      else
        a.replace a
        a.insert(5, '/') if a[5]!='/'
      end
    }
    respond_to do |format|
      if @announcement.save
        format.js { render_js announcements_path("page" => cookies['current_page']), '修改成功！' }
        # format.html { redirect_to @announcement, notice: 'Announcement was successfully updated.' }
        format.json { render :show, status: :ok, location: @announcement }
      else
        format.js { render_js announcements_path }
        # format.html { render :edit }
        format.json { render json: @announcement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /announcements/1
  # DELETE /announcements/1.json
  def destroy
    picture_path = 'public/upload/image/announcements/'+ @announcement.id
    if Dir.exist? picture_path
      FileUtils.rm_rf(picture_path)
    end
    @announcement.destroy
    respond_to do |format|
      format.js { render_js announcements_path("page" => cookies['current_page']) }
      # format.html { redirect_to announcements_url, notice: 'Announcement was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def warehouse_notice_index
    @notices = Warehouse::Notice.all
  end


  def batch_check
    @announcement = Announcement.where(:status => params[:status], :user_id => current_user.id).order('created_at DESC').first
    respond_to do |format|
      if @announcement.present?
        format.html { redirect_to announcement_path(@announcement) }
      else
        format.html { redirect_to announcements_path }
      end
    end
  end


  def next_check
    announcement= Announcement.find(params[:announcement_id])
    announcement.status = 1
    announcement.save
    @announcement = Announcement.where(:status => params[:status], :created_at => {"$lt" => announcement.created_at}).order('created_at DESC').first
    respond_to do |format|
      if @announcement.present?
        format.html { redirect_to announcement_path(@announcement) }
      else
        format.html { redirect_to announcements_path }
      end
    end

  end

  def next_check_out
    announcement = Announcement.find(params[:announcement_id])
    announcement.status = -1
    announcement.save
    @announcement = Announcement.where(:status => params[:status], :created_at => {"$lt" => announcement.created_at}).order('created_at DESC').first
    respond_to do |format|
      if @announcement.present?
        format.html { redirect_to announcement_path(@announcement) }
      else
        format.html { redirect_to announcements_path }
      end
    end
  end

  def next_delete
    announcement = Announcement.find(params[:announcement_id])
    picture_path = 'public/upload/image/announcements/'+ announcement.id
    if Dir.exist? picture_path
      FileUtils.rm_rf(picture_path)
    end
    announcement.destroy
    @announcement = Announcement.where(:status => params[:status], :created_at => {"$lt" => announcement.created_at}).order('created_at DESC').first
    respond_to do |format|
      if @announcement.present?
        format.html { redirect_to announcement_path(@announcement) }
      else
        format.html { redirect_to announcements_path }
      end
    end
  end

  def check
    @announcement = Announcement.find(params[:announcement_id])
    @announcement.update_attribute(:status, 1)
    respond_to do |format|
      format.html { redirect_to announcements_path("page" => cookies['current_page']), notice: '审核通过成功！' }
    end
  end

  def check_out
    @announcement = Announcement.find(params[:announcement_id])
    @announcement.update_attribute(:status, -1)
    respond_to do |format|
      format.html { redirect_to announcements_path("page" => cookies['current_page']), notice: '审核不通过成功！' }
    end
  end


  def batch

    resque_params = {}
    resque_params['announcement_category_id'] = params[:announcement_category_id]
    resque_params['current_user_id']= current_user.id.to_s

    a = Roo::Spreadsheet.open(params[:excel_file])
    a.each do |x|
      begin
        resque_params['x'] = x
        Resque.enqueue(AchieveAnnouncementsBatch, resque_params)
      rescue
      end
    end
    respond_to do |format|
      format.js { render_js announcements_path, '批量导入成功！' }
    end
  end

  def app_show
    @announcement = Announcement.find(params[:announcement_id])
    render :layout => nil
  end


  def stow
    @announcement = Announcement.find(params[:announcement_id])
    data ={}
    respond_to do |format|
      if !@announcement.customer_ids.include? params[:customer_id]
        @announcement.save
        data['flag'] = 1
        data['message'] = '收藏成功！'

      else
        data['flag'] = 0
        data['message'] = '收藏失败！你已经收藏过了哦'
      end
      format.json { render json: data }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_announcement
    @announcement = Announcement.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def announcement_params
    params.require(:announcement).permit(:title, :author, :description, :read_num, :is_top, :content, :status, :avatar, :announcement_category_id,
                                         :pic_path, :news_url, :release_time)
  end

end
