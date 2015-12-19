class AnnouncementsController < ApplicationController
  before_action :set_announcement, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:app_show]

  # GET /announcements
  # GET /announcements.json
  def index
    @announcements = Announcement.all.page(params[:page]).order('created_at DESC')
  end

  # GET /announcements/1
  # GET /announcements/1.json
  def show
    @announcement.update_attribute(:read_num, @announcement.read_num+1)
    if !@announcement.reader.include?(current_user.id)
      @announcement.reader << current_user.id
      @announcement.save
    end
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
    # respond_to do |format|
    #   if @announcement.save
    #     format.html { redirect_to @announcement, notice: 'Announcement was successfully created.' }
    #     format.json { render :show, status: :created, location: @announcement }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @announcement.errors, status: :unprocessable_entity }
    #   end
    # end
    if @announcement.save
    render_js announcements_path
    else
      render :new
    end
  end

  # PATCH/PUT /announcements/1
  # PATCH/PUT /announcements/1.json
  def update
    respond_to do |format|
      if @announcement.update(announcement_params)
        format.html { redirect_to @announcement, notice: 'Announcement was successfully updated.' }
        format.json { render :show, status: :ok, location: @announcement }
      else
        format.html { render :edit }
        format.json { render json: @announcement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /announcements/1
  # DELETE /announcements/1.json
  def destroy
    announcements_path = 'public/upload/image/announcements/'+ @announcement.id
    if Dir.exist? announcements_path
      FileUtils.rm_rf(announcements_path)
    end
    @announcement.destroy
    respond_to do |format|
      # format.html { redirect_to announcements_url, notice: 'Announcement was successfully destroyed.' }
      format.js { render_js announcements_url, notice: 'Announcement was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def warehouse_notice_index
    @notices = Warehouse::Notice.all
  end


  def check
    @announcement = Announcement.find(params[:announcement_id])
    respond_to do |format|
      if @announcement.update_attribute(:status, 1)
        format.html { redirect_to announcements_url, notice: '审核通过成功！' }
        format.json { head :no_content }
      else
        format.json { render json: @announcement.errors, status: :unprocessable_entity }
      end
      format.js
    end
  end

  def check_out
    @announcement = Announcement.find(params[:announcement_id])
    respond_to do |format|
      if @announcement.update_attribute(:status, -1)
        format.html { redirect_to announcements_url, notice: '审核不通过成功！' }
        format.json { head :no_content }
      else
        format.html { render :index }
        format.json { render json: @announcement.errors, status: :unprocessable_entity }
      end
    end
  end


  def batch
    @announcement_category_id = params[:announcement_category_id]
    a = Roo::Spreadsheet.open(params[:excel_data])
    a.each do |x|
      #建立模型
      announcement = Announcement.new
      announcement.announcement_category_id = @announcement_category_id
      b = announcement.id.to_s
      Dir.mkdir('public/upload/image/announcements/'+ b)
      announcement.title = x[0]
      announcement.source = x[2]
      announcement.release_time = x[3]
      # d = x[1].gsub(/\t/, '  ')
      #查找图片链接
      announcement.content = x[1].gsub(/http.*(jpg|png|jpeg)/) { |c|
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
      announcement.save
    end
    respond_to do |format|
      format.html { redirect_to :back, notice: '批量导入成功！' }
    end
  end

  def app_show
    @announcement = Announcement.find(params[:announcement_id])
    render :layout => nil
  end

  def search
    status_condition=params[:status] || ''
    title_condition=params[:title] || ''
    # category_condition=params[:announcement_category_id] || ''
    conditionParams = {}
    conditionParams['status'] = status_condition if status_condition.present?
    conditionParams['title'] = /#{title_condition}/ if title_condition.present?
    # conditionParams['announcement_category_id'] = category_condition if category_condition.present?
    @announcements = Announcement.where(conditionParams).page(params[:page]).order('created_at DESC')
    render :index
  end


  def data_table
    length = params[:length].to_i #页显示记录数
    start = params[:start].to_i #记录跳过的行数

    searchValue = params[:search][:value] #查询
    searchParams = {}
    searchParams['title'] = /#{searchValue}/

    tabledata = {}
    totalRows = Announcement.count
    tabledata['data'] = Announcement.where(searchParams).page((start/length)+1).per(length)
    tabledata['draw'] = params[:draw] #访问的次数
    tabledata['recordsTotal'] = totalRows
    tabledata['recordsFiltered'] = totalRows

    respond_to do |format|
      format.json { render json: tabledata }
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
