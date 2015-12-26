class AnnouncementsController < ApplicationController
  before_action :set_announcement, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:app_show]

  # GET /announcements
  # GET /announcements.json
  def index
    status_condition=params[:status] || ''
    title_condition=params[:title] || ''
    conditionParams = {}
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
    @announcement.author = current_user.name
    @announcement.read_num = 0
    @announcement.status = 0
    respond_to do |format|
      if @announcement.save
        format.js { render_js announcements_path }
        # format.html { redirect_to @announcement, notice: 'Announcement was successfully created.' }
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
    @announcement.is_top = params[:announcement]['is_top']
    @announcement.content = i.gsub(/src.*(jpg|png|jpeg)/) { |a|
      if !a.include? 'upload/image/announcements'
        c = a[5, a.length]
        uuid=SecureRandom.uuid
        # 下载
        open('public/upload/image/announcements/'+ @announcement.id + '/' + uuid + '.jpg', 'wb') do |file|
          begin
            file << open(c).read
            announcements.pic_path << '/upload/image/announcements/' + @announcement.id + '/' + uuid + '.jpg'
              # 替换content原图片链接并转化城IMG标签
          rescue
          end
        end
        a.replace 'src="/upload/image/announcements/' + @announcement.id + '/' + uuid + '.jpg'
      else
        a.replace a
        a.insert(5, '/')
      end
    }
    respond_to do |format|
      if @announcement.save
        format.js { render_js announcements_path }
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
      format.js { render_js announcements_path }
      format.html { redirect_to announcements_url, notice: 'Announcement was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def warehouse_notice_index
    @notices = Warehouse::Notice.all
  end


  def check
    page = params[:page]
    @announcement = Announcement.find(params[:announcement_id])
    # @announcement.update_attribute(:status, 1)
    # render_js announcements_path(page:params[:page]),notice: '审核通过成功！'
    respond_to do |format|
      if @announcement.update_attribute(:status, 1)

        format.js { render_js announcements_path+"?page="+page.to_s }
        # format.html { redirect_to announcements_path+"?page="+page, notice: '审核通过成功！' }
        format.json { render :index, status: :ok }
      else
        format.html { redirect_to announcements_url, notice: '审核失败！' }
      end
    end
  end

  def check_out
    page = params[:page]
    @announcement = Announcement.find(params[:announcement_id])
    # @announcement.update_attribute(:status, -1)
    # render_js announcements_path(page:params[:page]),notice: '审核不通过成功！'
    respond_to do |format|
      if @announcement.update_attribute(:status, -1)
        format.js { render_js announcements_path+"?page="+page.to_s  }
        # format.html { redirect_to announcements_path(page:params[:page]), notice: '审核不通过成功！' }
        format.json { render :index, status: :ok }
      else
        format.html { redirect_to announcements_url, notice: '审核失败！' }
      end
    end
  end


  def batch
    @announcement_category_id = params[:announcement_category_id]
    a = Roo::Spreadsheet.open(params[:excel_data])
    a.each do |x|
      @fwb = ""
      #建立模型
      announcement = Announcement.new
      announcement.announcement_category_id = @announcement_category_id
      b = announcement.id.to_s
      Dir.mkdir('public/upload/image/announcements/'+ b)
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
              announcement.pic_path << '/upload/image/announcements/' + b + '/' + uuid + '.jpg'
              # 下载
              open('public/upload/image/announcements/'+ b + '/' + uuid + '.jpg', 'wb') do |file|
                begin
                  file << open(c).read
                rescue
                end
              end

              # # 替换content原图片链接并转化城IMG标签
              c.replace "<div style = \"width:90%; margin:0 auto;\"><img style='width:100%;' src='/upload/image/announcements/#{b}/#{uuid}.jpg' /></div>"
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
      #保存
      announcement.save
    end
    respond_to do |format|
      format.js { render_js announcements_path }
    end
  end

  def app_show
    @announcement = Announcement.find(params[:announcement_id])
    render :layout => nil
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
