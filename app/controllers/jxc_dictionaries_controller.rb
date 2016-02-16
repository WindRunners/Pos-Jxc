class JxcDictionariesController < ApplicationController
  before_action :set_jxc_dictionary, only: [:show, :edit, :update, :destroy]

  def index
    @jxc_dictionaries = JxcDictionary.order_by(:created_at => :desc).page(params[:page]).per(10)
  end

  def show
  end

  def new
    @jxc_dictionary = JxcDictionary.new
  end

  def edit
  end

  def create
    @jxc_dictionary = JxcDictionary.new(jxc_dictionary_params)

    respond_to do |format|
      if @jxc_dictionary.save
        # format.html { redirect_to jxc_dictionaries_path, notice: '进销存字典创建成功.'  }
        # format.js { render_js jxc_dictionaries_path, notice: '进销存字典创建成功.'  }
        # format.json { render :show, status: :created, location: @jxc_dictionary }
        format.json { render json: get_render_common_json(@jxc_dictionary,jxc_dictionaries_path) }
      else
        # format.js { render_js new_jxc_dictionary_path }
        # format.json { render json: @jxc_dictionary.errors, status: :unprocessable_entity }
        format.json { render json: get_render_common_json(@jxc_dictionary) }
      end
    end
  end

  def update
    respond_to do |format|
      if @jxc_dictionary.update(jxc_dictionary_params)
        # format.html { redirect_to @jxc_dictionary, notice: '进销存字典更新成功.' }
        # format.js { render_js jxc_dictionaries_path(@jxc_dictionary), notice: '进销存字典更新成功.' }
        # format.json { render :show, status: :ok, location: @jxc_dictionary }
        format.json { render json: get_render_common_json(@jxc_dictionary,jxc_dictionaries_path) }
      else
        # format.js { render_js edit_jxc_dictionary_path }
        # format.json { render json: @jxc_dictionary.errors, status: :unprocessable_entity }
        format.json { render json: get_render_common_json(@jxc_dictionary) }
      end
    end
  end

  def destroy
    @jxc_dictionary.destroy
    respond_to do |format|
      format.js { render_js jxc_dictionaries_path, notice: '进销存字典删除成功.'  }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_jxc_dictionary
    @jxc_dictionary = JxcDictionary.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def jxc_dictionary_params
    params.require(:jxc_dictionary).permit(:dic, :dic_desc, :sort, :pinyin_code)
  end
end
