class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_filter :find_product

  def create
    @comment = @product.comments.build(comment_params)
    @comment.user = current_user

    if current_user.has_role? :supervisor and @product.supervisor == nil then
      @product.supervisor = current_user
    end

    State.all.each do |state|
      unless params[state.name].blank?
        @comment.state = state
      end
    end

    if @comment.save
      flash[:notice] = "Comment has been created."
      redirect_to @product
    else
      flash[:alert] = "Comment has not been created."
      render :template => "products/show"
    end
  end

  private

  def find_product
    @product = Product.find(params[:product_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
