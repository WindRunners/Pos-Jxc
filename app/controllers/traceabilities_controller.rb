class TraceabilitiesController < ApplicationController
  before_action :set_traceability, only: [:show, :edit, :update, :destroy]

  # GET /traceabilities
  # GET /traceabilities.json
  def index
    @traceabilities = Traceability.all
  end

  # GET /traceabilities/1
  # GET /traceabilities/1.json
  def show
  end

  # GET /traceabilities/new
  def new
    @traceability = Traceability.new
  end

  # GET /traceabilities/1/edit
  def edit
  end

  # POST /traceabilities
  # POST /traceabilities.json
  def create
    @traceability = Traceability.new(traceability_params)

    respond_to do |format|
      if @traceability.save
        format.html { redirect_to @traceability, notice: 'Traceability was successfully created.' }
        format.json { render :show, status: :created, location: @traceability }
      else
        format.html { render :new }
        format.json { render json: @traceability.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /traceabilities/1
  # PATCH/PUT /traceabilities/1.json
  def update
    respond_to do |format|
      if @traceability.update(traceability_params)
        format.html { redirect_to @traceability, notice: 'Traceability was successfully updated.' }
        format.json { render :show, status: :ok, location: @traceability }
      else
        format.html { render :edit }
        format.json { render json: @traceability.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /traceabilities/1
  # DELETE /traceabilities/1.json
  def destroy
    @traceability.destroy
    respond_to do |format|
      format.html { redirect_to traceabilities_url, notice: 'Traceability was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_traceability
      @traceability = Traceability.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def traceability_params
      params[:traceability]
    end
end
