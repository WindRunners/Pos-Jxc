class WinesController < ApplicationController
  before_action :set_wine, only: [:show, :edit, :update, :destroy]

  # GET /wines
  # GET /wines.json
  def index
    searchParams = {}
    searchParams['user_id'] = current_user.id
    @wines = Wine.where(searchParams)
    i = 0
    @wines.each do |w|
      i +=1 if w.created_at.today?
    end
    @data = {}
    @data['today'] = i
    @data['total'] = @wines.count
    @data
  end

  # GET /wines/1
  # GET /wines/1.json
  def show
  end

  # GET /wines/new
  def new
    @wine = Wine.new
  end

  # GET /wines/1/edit
  def edit
  end

  # POST /wines
  # POST /wines.json
  def create
    @wine = Wine.new(wine_params)
    @wine.user = current_user
    respond_to do |format|
      if @wine.save
        format.html { redirect_to @wine, notice: 'Wine was successfully created.' }
        format.json { render :show, status: :created, location: @wine }
      else
        format.html { render :new }
        format.json { render json: @wine.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wines/1
  # PATCH/PUT /wines/1.json
  def update
    respond_to do |format|
      if @wine.update(wine_params)
        format.html { redirect_to @wine, notice: 'Wine was successfully updated.' }
        format.json { render :show, status: :ok, location: @wine }
      else
        format.html { render :edit }
        format.json { render json: @wine.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wines/1
  # DELETE /wines/1.json
  def destroy
    @wine.destroy
    respond_to do |format|
      format.html { redirect_to wines_url, notice: 'Wine was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  def table
    length = params[:length].to_i #页显示记录数
    start = params[:start].to_i #记录跳过的行数

    searchValue = params[:search][:value] #查询
    searchParams = {}
    searchParams['name'] = /#{searchValue}/
    searchParams['user_id'] = current_user.id

    data = {}
    totalRows = Wine.count
    wine_data = []
    wines = Wine.where(searchParams).page((start/length)+1).per(length)
    wines.each do |w|
      w['user_name'] = User.find(w.user_id).name
      wine_data << w
    end
    data['data'] = wine_data
    data['draw'] = params[:draw] #访问的次数
    data['recordsTotal'] = totalRows
    data['recordsFiltered'] = totalRows

    respond_to do |format|
      format.json { render json: data }
    end
  end



  def turn_picture
    @wines = Wine.find(params[:wine_id])
    @turn_picture = @wines.pictures
  end

  def turn_picture_add
    @picture = Picture.new
    @picture.pic = params[:picture]['pic']
    @picture.type= params[:picture]['type']
    @picture.save
    @wines = Wine.find(params[:wine_id])
    @wines.pictures << @picture
    @wines.save
    redirect_to :wine_turn_picture
  end

  def turn_picture_reduce
    @picture = Picture.find(params[:picture_id])
    @wines = Wine.find(params[:wine_id])
    @wines.pictures.delete(@picture)
    @picture.destroy
    @wines.save
    redirect_to :wine_turn_picture
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
    redirect_to :wine_turn_picture
  end

  def introduce_show
    @wine = Wine.find(params[:wine_id])
    render :layout => nil
  end


  def mark
    @wine = Wine.find(params[:wine_id])
    @wine_marks = @wine.chateau_marks
  end

  def mark_reduce
    @chateau_mark = ChateauMark.find(params[:make_id])
    @wine = Wine.find(params[:wine_id])
    @wine.chateau_marks.delete(@chateau_mark)
    @chateau_mark.destroy
    @wine.save
    redirect_to :wine_mark
  end

  def mark_add
    @chateau_mark = ChateauMark.new
    @chateau_mark.name = params[:name]
    @chateau_mark.value = params[:value]
    @chateau_mark.save
    @wine = Wine.find(params[:wine_id])
    @wine.chateau_marks << @chateau_mark
    @wine.save
    redirect_to :wine_mark
  end

  def search
    status_condition=params[:status] || ''
    name_condition=params[:name] || ''
    conditionParams = {}
    conditionParams['status'] = status_condition if status_condition.present?
    conditionParams['name'] = /#{name_condition}/ if name_condition.present?
    @wines = Wine.where(conditionParams).page(params[:page]).order('created_at DESC')
    render :index
  end


  def check
    @wine = Wine.find(params[:wine_id])
    respond_to do |format|
      if @wine.update_attribute(:status, 1)
        format.html { redirect_to wines_url, notice: '审核通过成功！' }
        format.json { head :no_content }
      else
        format.json { render json: @wine.errors, status: :unprocessable_entity }
      end
      format.js
    end
  end

  def check_out
    @wine = Wine.find(params[:wine_id])
    respond_to do |format|
      if @wine.update_attribute(:status, -1)
        format.html { redirect_to wines_url, notice: '审核通过成功！' }
        format.json { head :no_content }
      else
        format.json { render json: @wine.errors, status: :unprocessable_entity }
      end
      format.js
    end
  end



  def upload
  p '1'
  @picture = Picture.new
  @picture.pic = params['upload']
  @picture.type = 2
  @picture.save
  @picture.pic.url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wine
      @wine = Wine.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wine_params
      params.require(:wine).permit(:name, :category, :description, :price, :hits, :sequence, :status, :logo,:ad)
    end
end
