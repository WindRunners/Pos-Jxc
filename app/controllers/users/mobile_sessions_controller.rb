class Users::MobileSessionsController < Devise::SessionsController
  # api_v1_user_session  /api/v1/user/session

  respond_to :json


  def create
    respond_to do |format|
      format.json do
        super do |user|
          if params[:user][:channel_id].present?
            channel = params[:user][:channel_type] + "|" + params[:user][:channel_id]
            unless user.userinfo.channel_ids.include? channel
              user.userinfo.channel_ids << channel
              user.userinfo.save
            end
          end
          user.name = user.userinfo.name
          user.shop_name = user.userinfo.shopname
        end
      end
    end
  end

  def destroy
    logger.info params

    super do |user|
      if params[:user][:channel_id].present?
        channel = params[:user][:channel_type] + "|" + params[:user][:channel_id]
        userinfo = Userinfo.find(params[:user][:userinfo_id])
        if userinfo.channel_ids.include? channel
          userinfo.channel_ids.delete channel
          userinfo.save
        end
      end
    end
  end

end