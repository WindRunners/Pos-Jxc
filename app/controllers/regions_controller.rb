class RegionsController < ApplicationController
  before_action :set_region, only: [:show, :edit, :update, :destroy]

  # GET /regions
  # GET /regions.json
  def index
    @region = Region.new
    @regions = Region.root.children.page(params[:page]).order('created_at DESC')
  end

  # GET /regions/1
  # GET /regions/1.json
  def show
  end

  # GET /regions/new
  def new
    @region = Region.new
  end

  # GET /regions/1/edit
  def edit
  end


  def children
    @regions = Region.find(params[:region_id])
    @children = @regions.children.page(params[:page]).order('created_at DESC')
  end

  # POST /regions
  # POST /regions.json
  def create
    @region = Region.new(region_params)
    @region.parent = Region.root
    respond_to do |format|
      if @region.save
        format.html { redirect_to @region, notice: 'Region was successfully created.' }
        format.json { render :show, status: :created, location: @region }
      else
        format.html { render :new }
        format.json { render json: @region.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /regions/1
  # PATCH/PUT /regions/1.json
  def update
    respond_to do |format|
      if @region.update(region_params)
        format.html { redirect_to @region, notice: 'Region was successfully updated.' }
        format.json { render :show, status: :ok, location: @region }
      else
        format.html { render :edit }
        format.json { render json: @region.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /regions/1
  # DELETE /regions/1.json
  def destroy
    @region.destroy
    respond_to do |format|
      format.html { redirect_to region_children_url(@region.parent.id), notice: 'Region was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_children
    children = Region.new(name:params[:name])
    children.parent = Region.find(params[:region_id])
    children.save
    redirect_to :region_children
  end

  def reduce_children
    redirect_to :region_children
  end


  def get_children
    @region = Region.find(params[:region_id])
    children_array = []
    @region.children.each do |c|
      children_hash = {}
      children_hash['name'] = c.name
      children_hash['id'] = c.id.to_s
      children_array << children_hash
    end
    respond_to do |format|
      format.json { render json: children_array }
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_region
    @region = Region.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def region_params
    params.require(:region).permit(:name)
  end
end
