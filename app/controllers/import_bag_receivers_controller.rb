class ImportBagReceiversController < ApplicationController
  before_action :set_import_bag_receiver, only: [:show, :edit, :update, :destroy]

  # GET /import_bag_receivers
  # GET /import_bag_receivers.json
  def index

    set_import_bag
    @import_bag_receivers = ImportBagReceiver.where({'import_bag_id'=> @import_bag.id,'receiver_mobile'=>/#{params[:mobile]}/}).page(params[:page])
  end

  # GET /import_bag_receivers/1
  # GET /import_bag_receivers/1.json
  def show

    @import_bag = @import_bag_receiver.import_bag
  end

  # GET /import_bag_receivers/new
  def new
    set_import_bag
    @import_bag_receiver = ImportBagReceiver.new
    @action = "create"
  end

  # GET /import_bag_receivers/1/edit
  def edit
    @import_bag = @import_bag_receiver.import_bag
    @action = "update"
  end

  # POST /import_bag_receivers
  # POST /import_bag_receivers.json
  def create

    @import_bag_receiver = ImportBagReceiver.new(import_bag_receiver_params)
    @import_bag_receiver['import_bag_id'] = params[:import_bag_id]

    @import_bag = @import_bag_receiver.import_bag
    #验证权限
    authorize  @import_bag ,:update?

    countRows = ImportBagReceiver.where(receiver_mobile: @import_bag_receiver.receiver_mobile,import_bag_id: params[:import_bag_id]).count

    # if countRows > 0
    #   render_js new_import_bag_import_bag_receiver_path(@import_bag)
    #   # redirect_to new_import_bag_import_bag_receiver_path(@import_bag), notice: "账号#{@import_bag_receiver.receiver_mobile}已经添加无需再添加!"
    #   return
    # end

    respond_to do |format|

      if countRows > 0

        format.json { render json: get_render_json(0,{'repeat'=>'当前会员已经添加！'}) }
      else

        if @import_bag_receiver.save
          format.json { render json: get_render_json(1,nil,import_bag_receiver_path(@import_bag_receiver)) }
        else
          format.json { render json: get_render_json(0,@import_bag_receiver.errors.messages) }
        end
      end
    end
  end

  # PATCH/PUT /import_bag_receivers/1
  # PATCH/PUT /import_bag_receivers/1.json
  def update

    #验证权限
    @import_bag = @import_bag_receiver.import_bag
    authorize  @import_bag ,:update?

    import_bag_receiver_bak = ImportBagReceiver.where(receiver_mobile: params[:import_bag_receiver][:receiver_mobile],import_bag_id: @import_bag.id).first

    respond_to do |format|

      if import_bag_receiver_bak.present? && import_bag_receiver_bak.id!=@import_bag_receiver.id

        format.json { render json: get_render_json(0,{'repeat'=>'当前会员已经添加！'}) }
      else

        if @import_bag_receiver.update(import_bag_receiver_params)

          format.json { render json: get_render_json(1,nil,import_bag_receiver_path(@import_bag_receiver)) }
        else
          format.json { render json: get_render_json(0,@import_bag_receiver.errors.messages) }
        end
      end
    end
  end

  # DELETE /import_bag_receivers/1
  # DELETE /import_bag_receivers/1.json
  def destroy

    import_bag = @import_bag_receiver.import_bag

    #验证权限
    #验证权限
    authorize  import_bag ,:update?
    @import_bag_receiver.destroy
    respond_to do |format|
      # format.json { {'path'=>import_bag_import_bag_receivers_path} }
      format.js {render_js import_bag_import_bag_receivers_path(import_bag)}
      # format.html { redirect_to :back, notice: '目标账号删除成功!' }
      # format.json { render json: {'path'=>import_bag_import_bag_receivers_path(import_bag)} }
      # format.json { head :no_content }
    end
  end

  def batch

    #验证权限
    @import_bag = ImportBag.find(params[:import_bag_id])
    authorize  @import_bag ,:update?

    import_bag_receivers = []
    a = Roo::Spreadsheet.open(params[:excel_data])
    a.each do |x|

      mobile = x[0].to_s
      next if !mobile.present? || mobile.match(/^\d{11}$/).nil?

      #如果当前电话号码存在跳过
      next if ImportBagReceiver.where(receiver_mobile: mobile,import_bag_id: params[:import_bag_id]).count > 0
      #建立模型
      import_bag_receiver = ImportBagReceiver.new(receiver_mobile: mobile,memo: x[1],import_bag_id: params[:import_bag_id])
      import_bag_receivers << import_bag_receiver.as_document
    end

    #批量插入
    batchResult = ImportBagReceiver.collection.insert_many(import_bag_receivers) if !import_bag_receivers.empty?
    p import_bag_import_bag_receivers_path(@import_bag)
    respond_to do |format|
      format.js {render_js import_bag_import_bag_receivers_path(@import_bag)}
      # format.html { redirect_to :back, notice: "批量导入成功#{batchResult.as_json["results"]["n"]}条！" }
    end
  end

  def down_templ

    io = File.open("public/template/import_bag_receivers/template.xlsx")
    io.binmode
    send_data(io.read,:filename => "导入模板.xlsx",:disposition => 'attachment')
    io.close
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_import_bag_receiver
      @import_bag_receiver = ImportBagReceiver.find(params[:id])
    end

    # 设置导入包
    def set_import_bag
      @import_bag = ImportBag.find(params[:import_bag_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def import_bag_receiver_params
      params.require(:import_bag_receiver).permit(:receiver_mobile, :memo)
    end
end
