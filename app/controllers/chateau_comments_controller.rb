class ChateauCommentsController < ApplicationController
  before_action :set_chateau_comment, only: [:show, :edit, :update, :destroy]

  # GET /chateau_comments
  # GET /chateau_comments.json
  def index
    @chateau_comments = ChateauComment.all
  end

  # GET /chateau_comments/1
  # GET /chateau_comments/1.json
  def show
  end

  # GET /chateau_comments/new
  def new
    @chateau_comment = ChateauComment.new
  end

  # GET /chateau_comments/1/edit
  def edit
  end

  # POST /chateau_comments
  # POST /chateau_comments.json
  def create
    @chateau_comment = ChateauComment.new(chateau_comment_params)

    respond_to do |format|
      if @chateau_comment.save
        format.html { redirect_to @chateau_comment, notice: 'Chateau comment was successfully created.' }
        format.json { render :show, status: :created, location: @chateau_comment }
      else
        format.html { render :new }
        format.json { render json: @chateau_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /chateau_comments/1
  # PATCH/PUT /chateau_comments/1.json
  def update
    respond_to do |format|
      if @chateau_comment.update(chateau_comment_params)
        format.html { redirect_to @chateau_comment, notice: 'Chateau comment was successfully updated.' }
        format.json { render :show, status: :ok, location: @chateau_comment }
      else
        format.html { render :edit }
        format.json { render json: @chateau_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chateau_comments/1
  # DELETE /chateau_comments/1.json
  def destroy
    @chateau_comment.destroy
    respond_to do |format|
      format.html { redirect_to chateau_comments_url, notice: 'Chateau comment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end




  def add_comment
    @chateau_comment = ChateauComment.new(chateau_comment_params)
    if @chateau_comment.save
      return {"flag":"1","message":"保存成功！"}
    else
      return {"flag":"0","message":"保存失败！"}
    end

  end


  def add_hits

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chateau_comment
      @chateau_comment = ChateauComment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def chateau_comment_params
      params.require(:chateau_comment).permit(:content, :status, :hits)
    end
end
