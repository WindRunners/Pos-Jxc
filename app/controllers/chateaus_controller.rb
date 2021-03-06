class ChateausController < ApplicationController
  before_action :set_chateau, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:introduce_show]

  # GET /chateaus
  # GET /chateaus.json
  def index
    searchParams = {}
    status_condition=params[:status] || ''
    name_condition=params[:name] || ''
    searchParams['status'] = status_condition if status_condition.present?
    searchParams['name'] = /#{name_condition}/ if name_condition.present?
    @data ={}
    @data['chateaus'] =Chateau.where(searchParams).page(params[:page]).order('created_at DESC')
    @data['count'] = Chateau.count
    @data['user_count'] = current_user.chateaus.count
    @data['today_count'] = Chateau.where(:user_id => current_user.id,:created_at => {"$gt"=>Time.now.strftime("%Y/%m/%d")+ " 00:00:00"}).count
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
          pic_file =open(c).read
          file << pic_file
          pic_file.close
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
        format.js { render_js chateaus_path }
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
            pic_file =open(c).read
            file << pic_file
            pic_file.close
            @chateau.pic_path << '/upload/image/chateaus/' + @chateau.id + '/' + uuid + '.jpg'
              # 替换content原图片链接并转化城IMG标签
          rescue
          end
        end
        a.replace 'src="/upload/image/chateaus/' + @chateau.id + '/' + uuid + '.jpg'
      else
        a.replace a
        a.insert(5, '/') if a[5]!='/'
      end
    }
    respond_to do |format|
      if @chateau.update(chateau_params)
        format.js { render_js chateaus_path("page" => cookies['current_page']) }
        format.json { render :show, status: :ok, location: @chateau }
      else
        format.html { render :edit }
        format.json { render json: @chateau.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chateaus/1
  # DELETE /chateaus/1.json
  def destroy
    case_folder = 'public/upload/image/chateaus/'+ @chateau.id
    if Dir.exist? case_folder
      FileUtils.rm_rf(case_folder)
    end
    @chateau.pictures.destroy
    @chateau.chateau_marks.destroy
    @chateau.chateau_introduce.destroy
    @chateau.destroy
    respond_to do |format|
      format.js { render_js chateaus_path("page" => cookies['current_page']) }
      format.json { head :no_content }
    end
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

    respond_to do |format|
      if @chateau.save
        format.js { render_js chateau_turn_picture_path }
      else
        format.html { render :turn_picture }
      end
    end
  end

  def turn_picture_reduce
    @picture = Picture.find(params[:picture_id])
    @chateau = Chateau.find(params[:chateau_id])
    @chateau.pictures.delete(@picture)
    @picture.destroy
    respond_to do |format|
      if @chateau.save
        format.js { render_js chateau_turn_picture_path }
      else
        format.html { render :turn_picture }
      end
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

    }
    respond_to do |format|
      if @chateau.save
        format.js { render_js chateau_turn_picture_path }
      else
        format.html { render :turn_picture }
      end
    end
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
    region_str = ""
    region_array = @chateau.region.ancestors_and_self.map{|c|c.name}.drop(1) if @chateau.region.present?
    region_array.each do |r|
      if region_str == ""
        region_str+= r
      else
        region_str+= ">>#{r}"
      end
    end
    @data['region_str'] = region_str
    @data
    render :layout => nil
  end


  def chateau_mark
    @data = {}
    @chateau = Chateau.find(params[:chateau_id])
    @data['chateau_marks'] = @chateau.chateau_marks
    @data['chateau'] =@chateau
    @data
  end

  def chateau_mark_reduce
    @chateau_mark = ChateauMark.find(params[:chateau_make_id])
    @chateau = Chateau.find(params[:chateau_id])
    @chateau.chateau_marks.delete(@chateau_mark)
    @chateau_mark.destroy
    @chateau.save
    respond_to do |format|
      if @chateau.save
        format.js { render_js chateau_chateau_mark_path }
      else
        format.html { render :chateau_mark }
      end
    end
  end

  def chateau_mark_add
    @chateau_mark = ChateauMark.new
    @chateau_mark.name = params[:name]
    @chateau_mark.value = params[:value]
    @chateau_mark.save
    @chateau = Chateau.find(params[:chateau_id])
    @chateau.chateau_marks << @chateau_mark
    @chateau.save
    respond_to do |format|
      if @chateau.save
        format.js { render_js chateau_chateau_mark_path }
      else
        format.html { render :chateau_mark }
      end
    end
  end



  def batch_check
    @chateau = Chateau.where(:status => params[:status]).order('created_at DESC').first
    respond_to do |format|
      if @chateau.present?
        format.html { redirect_to chateau_path(@chateau) }
      else
        format.html { redirect_to chateaus_path }
      end
    end
  end


  def next_check
    chateau = Chateau.find(params[:chateau_id])
    chateau.status = 1
    chateau.save
    @chateau = Chateau.where(:status => params[:status], :created_at => {"$lt" => chateau.created_at}).order('created_at DESC').first
    respond_to do |format|
      if @chateau.present?
        format.html { redirect_to chateau_path(@chateau) }
      else
        format.html { redirect_to chateaus_path }
      end
    end
  end


  def next_check_out
    chateau = Chateau.find(params[:chateau_id])
    chateau.status = -1
    chateau.save
    @chateau = Chateau.where(:status => params[:status], :created_at => {"$lt" => chateau.created_at}).order('created_at DESC').first
    respond_to do |format|
      if @chateau.present?
        format.html { redirect_to chateau_path(@chateau) }
      else
        format.html { redirect_to chateaus_path }
      end
    end
  end


  def check
    @chateau = Chateau.find(params[:chateau_id])
    @chateau.update_attribute(:status, 1)
    respond_to do |format|
      format.html { redirect_to chateaus_path("page" => cookies['current_page']) }
    end
  end


  def check_out
    @chateau = Chateau.find(params[:chateau_id])
    @chateau.update_attribute(:status, -1)
    respond_to do |format|
      format.html { redirect_to chateaus_path("page" => cookies['current_page']) }
    end
  end

  def workload
    @data ={}
    @data['work_array'] = []
    User.where(:role_ids=>{"$in"=>[Role.where({"name"=>"jiu_world"}).first.id]}).each do |u|
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
        @data['work_array'] << work
      end
    end
    @data['chateaus'] = Chateau.where(:status => -1,:user_id=>current_user.id)
    @data
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
        format.html { redirect_to chateau_wines_path(@chateau) }
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
