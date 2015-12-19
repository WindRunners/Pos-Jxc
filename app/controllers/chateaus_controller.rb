class ChateausController < ApplicationController
  before_action :set_chateau, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:introduce_show]

  # GET /chateaus
  # GET /chateaus.json
  def index

    searchParams = {}
    searchParams['user_id'] = current_user.id
    @user_chateaus= Chateau.where(searchParams)
    i = 0
    @user_chateaus.each do |c|
      i +=1 if c.created_at.today?
    end
    @data ={}
    @data['chateaus'] =Chateau.all.page(params[:page]).order('created_at DESC')
    @data['count'] = Chateau.count
    @data['user_count'] = current_user.chateaus.count
    @data['today_count'] = i
    @data
  end

  # GET /chateaus/1
  # GET /chateaus/1.json
  def show
  end

  # GET /chateaus/new
  def new
    @chateau = Chateau.new
  end

  # GET /chateaus/1/edit
  def edit

  end

  # POST /chateaus
  # POST /chateaus.json
  def create
    @chateau = Chateau.new(chateau_params)
    @chateau.user = current_user
    @chateau.pic_path = []
    chateau_id = @chateau.id.to_s
    introduce = params[:chateau]['chateau_introduce']['introduce']
    Dir.mkdir('public/upload/image/chateaus/'+ chateau_id)
    #查找图片链接
    @chateau_introduce = ChateauIntroduce.new
    @chateau_introduce.introduce = introduce.gsub(/src.*(jpg|png|jpeg)/) { |a|
      c = a[5, a.length]
      uuid=SecureRandom.uuid
      # 下载
      open('public/upload/image/chateaus/'+ chateau_id + '/' + uuid + '.jpg', 'wb') do |file|
        begin
          file << open(c).read
          @chateau.pic_path << '/upload/image/chateaus/' + chateau_id + '/' + uuid + '.jpg'
        rescue
        end
      end
      # 替换content原图片链接并转化城IMG标签
      a.replace 'src="/upload/image/chateaus/' + chateau_id + '/' + uuid + '.jpg'
    }
    @chateau.chateau_introduce = @chateau_introduce
    @chateau_introduce.save
    respond_to do |format|
      if @chateau.save
        format.html { redirect_to @chateau, notice: 'Chateau was successfully created.' }
        format.json { render :show, status: :created, location: @chateau }
      else
        format.html { render :new }
        format.json { render json: @chateau.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /chateaus/1
  # PATCH/PUT /chateaus/1.json
  def update
    i = params[:chateau]['chateau_introduce']['introduce']
    @chateau.chateau_introduce.introduce = i.gsub(/src.*(jpg|png|jpeg)/) { |a|
      if !a.include? 'upload/image/chateaus'
        c = a[5, a.length]
        uuid=SecureRandom.uuid
        # 下载
        open('public/upload/image/chateaus/'+ @chateau.id + '/' + uuid + '.jpg', 'wb') do |file|
          begin
            file << open(c).read
            @chateau.pic_path << '/upload/image/chateaus/' + @chateau.id + '/' + uuid + '.jpg'
              # 替换content原图片链接并转化城IMG标签
          rescue
          end
        end
        a.replace 'src="/upload/image/chateaus/' + @chateau.id + '/' + uuid + '.jpg'
      else
        a.replace a
      end
    }

    if @chateau.save
      render_js chateaus_path
    else
      render :edit
    end
    # respond_to do |format|
    #   if @chateau.update(chateau_params)
    #     format.html { redirect_to @chateau, notice: 'Chateau was successfully updated.' }
    #     format.json { render :show, status: :ok, location: @chateau }
    #   else
    #     format.html { render :edit }
    #     format.json { render json: @chateau.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /chateaus/1
  # DELETE /chateaus/1.json
  def destroy
    case_folder = 'public/upload/image/chateaus/'+ @chateau.id
    if Dir.exist? case_folder
      FileUtils.rm_rf(case_folder)
    end
    @chateau.destroy
    render_js chateaus_path
    # respond_to do |format|
    #   format.html { redirect_to chateaus_url, notice: 'Chateau was successfully destroyed.' }
    #   format.json { head :no_content }
    # end
  end

  def turn_picture
    @data = {}
    @chateau = Chateau.find(params[:chateau_id])
    @data['chateau'] = @chateau
    @data['turn_picture'] = @chateau.pictures
    @data
  end

  def turn_picture_add
    @picture = Picture.new
    @picture.pic = params[:picture]['pic']
    @picture.type= params[:picture]['type']
    @picture.save
    @chateau = Chateau.find(params[:chateau_id])
    @chateau.pictures << @picture
    if @chateau.save
      render_js chateaus_path
    else
      render :turn_picture
    end
  end

  def turn_picture_reduce
    @picture = Picture.find(params[:picture_id])
    @chateau = Chateau.find(params[:chateau_id])
    @chateau.pictures.delete(@picture)
    @picture.destroy
    if @chateau.save
      render_js chateaus_path
    else
      render :turn_picture
    end
  end

  def turn_picture_urls
    params[:urls].gsub(/http.*(jpg|png|jpeg)/) { |c|
      @picture = Picture.new
      @picture.type= params[:type]
      uuid=SecureRandom.uuid
      open('public/upload/image/chateaus/'+ params[:chateau_id] + '/' + uuid + '.jpg', 'wb') do |file|
        file << open(c).read
        @picture.pic = file
        File.delete('public/upload/image/chateaus/'+ params[:chateau_id] + '/' + uuid + '.jpg')
      end
      @picture.save
      @chateau = Chateau.find(params[:chateau_id])
      @chateau.pictures << @picture
      @chateau.save
    }

    render_js chateaus_path
  end

  def introduce_show
    @data ={}
    @chateau = Chateau.find(params[:chateau_id])
    @chateau.wines << Wine.all
    @data['chateau'] = @chateau
    @data['introduce'] = @chateau.chateau_introduce.introduce
    mark_array = []
    @chateau.chateau_marks.each do |m|
      mark ={}
      mark[m.name] = m.value
      mark_array<< mark
    end
    @data['mark'] = mark_array
    @data
    render :layout => nil
  end


  def chateau_mark
    @chateau = Chateau.find(params[:chateau_id])
    @chateau_marks = @chateau.chateau_marks
  end

  def chateau_mark_reduce
    @chateau_mark = ChateauMark.find(params[:chateau_make_id])
    @chateau = Chateau.find(params[:chateau_id])
    @chateau.chateau_marks.delete(@chateau_mark)
    @chateau_mark.destroy
    @chateau.save
    redirect_to :chateau_chateau_mark
  end

  def chateau_mark_add
    @chateau_mark = ChateauMark.new
    @chateau_mark.name = params[:name]
    @chateau_mark.value = params[:value]
    @chateau_mark.save
    @chateau = Chateau.find(params[:chateau_id])
    @chateau.chateau_marks << @chateau_mark
    @chateau.save
    redirect_to :chateau_chateau_mark
  end

  def search
    @data ={}
    status_condition=params[:status] || ''
    name_condition=params[:name] || ''
    conditionParams = {}
    conditionParams['status'] = status_condition if status_condition.present?
    conditionParams['name'] = /#{name_condition}/ if name_condition.present?
    @data['chateaus'] = Chateau.where(conditionParams).page(params[:page]).order('created_at DESC')
    render :index
  end


  def check
    @chateau = Chateau.find(params[:chateau_id])
    respond_to do |format|
      if @chateau.update_attribute(:status, 1)
        format.html { redirect_to :back, notice: @chateau.name+'审核通过成功！' }
        format.json { head :no_content }
      else
        format.json { render json: @chateau.errors, status: :unprocessable_entity }
      end
      format.js
    end
  end

  def check_out
    @chateau = Chateau.find(params[:chateau_id])
    respond_to do |format|
      if @chateau.update_attribute(:status, -1)
        format.html { redirect_to :back, notice: @chateau.name + '审核不通过成功！' }
        format.json { head :no_content }
      else
        format.json { render json: @chateau.errors, status: :unprocessable_entity }
      end
      format.js
    end
  end

  def workload
    @users = User.all
    @work_array = []
    User.all.each do |u|
      if !u.chateaus.empty?
        work = {}
        work['user_id'] = u.id
        work['user_name'] = u.name
        work['pass_chateau'] = u.chateaus.count
        work['pass_check'] = u.chateaus.where(:status => 1).count
        i = 0
        j = 0
        u.chateaus.each do |c|
          i +=1 if c.created_at.today?
          j +=1 if c.status == 1 && c.created_at.today?
        end
        work['today_chateau'] = i
        work['today_check'] = j
        @work_array << work
      end
    end
    @work_array
  end


  def relate_wine
    @chateau = Chateau.find(params[:chateau_id])
    @wine = Wine.find(params[:wine_id])
    @chateau.wines << @wine
    if @chateau.save
      render json: @wine, status: :ok
    else
      render json: @wine.error, status: :error
    end
  end

  def resolve_wine
    @chateau = Chateau.find(params[:chateau_id])
    @wine = Wine.find(params[:wine_id])
    @chateau.wines.delete(@wine)
    respond_to do |format|
      if @chateau.save
        format.html { redirect_to '/chateaus/'+@chateau.id+'/wines', notice: @chateau.name + '于' + @wine.name + '解除关联成功！' }
        format.json { head :no_content }
      else
        format.json { render json: @chateau.errors, status: :unprocessable_entity }
      end
      format.js
    end
  end


  def wines
    @chateau = Chateau.find(params[:chateau_id])
    @wines = Chateau.find(params[:chateau_id]).wines
    @data = {}
    @data['chateau'] =@chateau
    @data['wines'] =@wines
    @data
  end


  def ex_pic
    Chateau.all.each do |c|
      if c.pictures.count > 0
        if !Dir.exist? 'public/chateaus/'+ c.name
          Dir.mkdir('public/chateaus/'+ c.name)
        end
        c.pictures.each do |p|
          uuid=SecureRandom.uuid
          open('public/chateaus/'+ c.name + '/' + uuid + '.jpg', 'wb') do |file|
            begin
              file << open('http://10.99.99.206:81'+p.pic.url).read
            rescue
            end
          end
        end
      end
    end
    respond_to do |format|
      format.html { redirect_to chateaus_path, notice: '图片导出成功！' }
      format.json { head :no_content }
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_chateau
    @chateau = Chateau.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def chateau_params
    params.require(:chateau).permit(:category, :name, :owner, :region, :address, :phone, :urls, :logo, :sequence, :hits, :pic_path, :picture)
  end

end
